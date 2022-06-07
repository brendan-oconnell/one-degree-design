require "json"
require "open-uri"
require "nokogiri"

class WebsitesController < ApplicationController
  def create
    # if website.url.exists? @website = Website.find_by_url(website.url)
    @website = Website.new(website_params)
    @website.user = current_user

    if @website.valid?
      @version = create_version(@website)
      @website.save
      redirect_to version_path(version)
    else
    end
  end

  private

  def website_params
    params.require(:website).permit(:url, :user, photos: [])
  end

  def website_carbon_api(url)
    carbonurl = "https://api.websitecarbon.com/site?url=#{url}"
    carbon = URI.open(carbonurl).read
    carbon_infos = JSON.parse(carbon)
  end

  def compile_photos_with_cloudinary(html_doc)
    @photos = []
    html_doc.search("img").each do |image|
      query = Cloudinary::Uploader.upload(image.attributes["src"].value)
      @photos << {
        bytes: query["bytes"],
        url: query["url"]
      }
    end
    @photos.sort_by! { |photo| photo[:bytes] }
    @version.photos = @photos.reverse.first(3)

    # photos_size
    all_images_size = 0
    @photos.each { |photo| all_images_size += photo[:bytes] }
  end

  def create_version(website)
    # if website url does not include https then add it or must match
    url = website.url
    html_file = URI.open(url).read
    html_doc = Nokogiri::HTML(html_file)

    # carbon_infos = website_carbon_api(url)
    # version = Version.new(website_id: website.id, green_hosting: carbon_infos["green"], bytes: carbon_infos["bytes"], cleaner_than: carbon_infos["cleanerThan"], adjusted_bytes: carbon_infos["statistics"]["adjustedBytes"], energy: carbon_infos["statistics"]["energy"], co2: carbon_infos["statistics"]["co2"]["grid"]["grams"])
    @version = Version.new

    # compile_photos_with_cloudinary(html_doc)


    # background and font scraping

    stylesheet_links = []
    html_doc.search("link").each do |link|
      stylesheet_links << link.attributes["href"].value if link.attributes["type"].value == "text/css"
    end

    raise

    style_file = URI.open(stylesheet).read

    style_file.scan(/font-family:[",'].{1,22}[",']/)
    style_file.scan(/background:.{1,16};/)
    raise

    # window.getComputedStyle(document.querySelector("h1")).font

    # :fonts_file_size, :background_color)

    # save
    # version.save
  end


  # def version_params
  #   params.require(:version).permit(:website_id, :green_hosting, :bytes, :cleaner_than, :adjusted_bytes, :energy, :co2, :all_images_size, :fonts_file_size, :background_color)
  # end
end
