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

  def create_version(website)
    url = website.url
    html_file = URI.open(url).read
    html_doc = Nokogiri::HTML(html_file)

    # carbon_infos = website_carbon_api(url)

    # version = Version.new(website_id: website.id, green_hosting: carbon_infos["green"], bytes: carbon_infos["bytes"], cleaner_than: carbon_infos["cleanerThan"], adjusted_bytes: carbon_infos["statistics"]["adjustedBytes"], energy: carbon_infos["statistics"]["energy"], co2: carbon_infos["statistics"]["co2"]["grid"]["grams"])
    @version = Version.new
    @photos = {}

    # image Magick
    html_doc.search("img").each_with_index do |image, index|
      # regex on src?
      query = Cloudinary::Uploader.upload(image.attributes["data-src"].value)
      # image hash
      @photos[index] = {
        bytes: query["bytes"],
        url: query["url"]
      }
      puts @version.photos
    end
    raise

    # background and font scraping

    # stylesheet = html_doc.search("link")
    # raise


    # all_images_size, :fonts_file_size, :background_color)

    # save
    # version.save
  end


  # def version_params
  #   params.require(:version).permit(:website_id, :green_hosting, :bytes, :cleaner_than, :adjusted_bytes, :energy, :co2, :all_images_size, :fonts_file_size, :background_color)
  # end
end


# def create_version(website)
#   url = website.url
#   html_file = URI.open(url).read
#   html_doc = Nokogiri::HTML(html_file)
#   version = Version.new

#   # carbon_infos = website_carbon_api(url)

#   # image Magick

#   array_of_images = []
#   html_doc.search("img").each_with_index do |image, index|
#     # Cloudinary::Uploader.upload(image.attributes["src"].value)
#     file = URI.open(image.attributes["src"].value)
#     version.photos.attach(io: file, filename: "#{version.id}0#{index}", content_type: 'image/png' )
#     # array_of_images << cloud_image
#   end
#   photo_array = []
#   version.photos.each do |photo|
#     photo_array << photo.key
#   end
#   raise

#   # background and font scraping

#   # stylesheet = html_doc.search("link")
#   # raise


#   # all_images_size, :fonts_file_size, :background_color)

#   # save
#   # version(website_id: website.id, green_hosting: carbon_infos["green"], bytes: carbon_infos["bytes"], cleaner_than: carbon_infos["cleanerThan"], adjusted_bytes: carbon_infos["statistics"]["adjustedBytes"], energy: carbon_infos["statistics"]["energy"], co2: carbon_infos["statistics"]["co2"]["grid"]["grams"])
#   # version.save
# end
