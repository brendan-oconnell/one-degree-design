require "json"
require "open-uri"

class WebsitesController < ApplicationController
  def create
    @website = Website.new(website_params)
    @website.user = current_user
    if @website.valid?
      @website.save
      @version = create_version(@website)
      redirect_to version_path(@version)
    else
    end
  end

  private

  def website_params
    params.require(:website).permit(:url, :user)
  end

  def create_version(website)
    # website carbon
    carbonurl = "https://api.websitecarbon.com/site?url=#{website.url}"
    carbon = URI.open(carbonurl).read
    carbon_infos = JSON.parse(carbon)
    version = Version.new(website_id: website.id, green_hosting: carbon_infos["green"], bytes: carbon_infos["bytes"], cleaner_than: carbon_infos["cleanerThan"], adjusted_bytes: carbon_infos["statistics"]["adjustedBytes"], energy: carbon_infos["statistics"]["energy"], co2: carbon_infos["statistics"]["co2"]["grid"]["grams"])

    # image Magick


    # background and font scraping


    # all_images_size, :fonts_file_size, :background_color)

    # save
    version.save
  end

  # def version_params
  #   params.require(:version).permit(:website_id, :green_hosting, :bytes, :cleaner_than, :adjusted_bytes, :energy, :co2, :all_images_size, :fonts_file_size, :background_color)
  # end
end
