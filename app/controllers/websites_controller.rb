require "json"

class WebsitesController < ApplicationController

  def create
    # create the website if new for the user otherwise a new version of the website
    # user functionality for the dashboard is currently disabled.
    user_url = "https://www.#{website_params[:url]}"
    # existing_website = Website.find_by_url(user_url)

    # if Website.find_by_url(user_url) && existing_website.user == current_or_guest_user
    #   @website = Website.find_by_url(user_url)
    # else
       @website = Website.new(website_params)
       @website.url = user_url
       @website.user = current_or_guest_user unless current_or_guest_user.nil?
    # end
    @website.url = user_url

    if @website.valid?
      @website.save
      create_version(@website)
      redirect_to version_path(@version)

    else
      redirect_to scrapingerror_path
    end

  end

  private

  def website_params
    params.require(:website).permit(:url, :user, photos: [])
  end

  def create_version(website)
    last_version = Version.find_by_website_id(@website.id)
    url = @website.url
    reuse_recent_version(last_version, url)
    # @version = Version.new
    # @version.update(website_id: website.id)

    FontsBackgroundsScrapingJob.perform_later(@version, @website)
    ImageScrapingJob.perform_later(@version, @website)
    CarbonApiJob.perform_later(website.url, @version)
    # wait before loading the results page, to give at least some of the scraping and API to load.
    sleep 10
  end

  def reuse_recent_version(last_version, url)
    # Pseudo: reuse the version if the new request is less than 24h
    # if last_version && (Time.now.utc - last_version.created_at) < 86_400
    #   @version = last_version
    #   @version[:carbonapi_updated] = false
    #   carbon_infos = nil
    # else
      @version = Version.new
      @version.update(website_id: @website.id)
    # end
  end

end
