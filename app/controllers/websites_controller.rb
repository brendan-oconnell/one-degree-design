require "json"
require "open-uri"
require "nokogiri"
require "fastimage"

class WebsitesController < ApplicationController
  def create
    existing_website = Website.find_by_url("https://www.#{website_params[:url]}")
    if Website.find_by_url("https://www.#{website_params[:url]}") && existing_website.user == current_user
      @website = Website.find_by_url("https://www.#{website_params[:url]}")
    else
      @website = Website.new(website_params)
      @website.url = "https://www.#{website_params[:url]}"
      @website.user = current_user unless current_user.nil?
    end
    if @website.valid?
      @website.save
      create_version(@website)
      @version.save
      # CloudinaryCallJob.perform_later(@version)
      redirect_to version_path(@version)
    else
      render :new
    end
  end

  private

  def website_params
    params.require(:website).permit(:url, :user, photos: [])
  end

  def website_carbon_api(url)
    # make a new version only if last version has been made more than 24 horus ago
    carbonurl = "https://api.websitecarbon.com/site?url=#{url}"
    carbon = URI.open(carbonurl).read
    carbon_infos = JSON.parse(carbon)
  end

  def fonts_and_backgrounds_scraping(html_doc)
    stylesheet_links = []
    stylesheet_corrected_links = []
    # add all stylesheets to array
    html_doc.search("link").each do |link|
      stylesheet_links << link.attributes["href"].value if link.attributes["rel"].value == "stylesheet"
    end
    # if stylesheet begins with https://www, don't do anything with it.
    stylesheet_links.each do |stylesheet|
      if stylesheet.start_with?("http")
        stylesheet_corrected_links << stylesheet
      else
        modified_stylesheet_url = stylesheet.insert(0, @website.url)
        stylesheet_corrected_links << modified_stylesheet_url
      end
    end

    # TODO:

    @font_families = []
    @backgrounds = []

    stylesheet_corrected_links.each do |stylesheet|
      style_file = URI.open(stylesheet).read

      @font_families << style_file.scan(/font-family:[",'](.{1,22})[",']/)
      @backgrounds << style_file.scan(/background[-color]*:(\S{1,16});/)
    end
    @font_families.flatten!.map! { |font| font.downcase.gsub(/['"]/, "") }
    @backgrounds.flatten!

    # if his font is not downloaded applaud
    default_font_families = ["open sans", "times", "times new roman", "georgia", "serif", "Verdana", "Arial", "Helvetica", "sans-serif", "courier", "monospace", "lucida console", "cursive", "fantasy" ]

    @font_families.reject! { |font| default_font_families.include?(font.downcase) }

    @font_families.sort_by! { |font| @font_families.count(font) }.reverse!.uniq!
    @backgrounds.sort_by! { |color| @backgrounds.count(color) }.reverse!.uniq!
  end
  def image_scraping(html_doc)
    @photos = []
    html_doc.search("img").each do |image|
      # @photos << image.attributes["src"].value unless image.attributes["alt"].nil?
      unless image.attributes["alt"].nil?
        src_value = image.attributes["data-src"] ? image.attributes["data-src"].value : image.attributes["src"].value
        if src_value.start_with?("http")
        else
          src_value.insert(0, @website.url)
        end
        dimensions = FastImage.size(src_value)
        type = FastImage.type(src_value)
        size = dimensions[0] * dimensions[1]
        @photos << {
          url: src_value,
          size: size,
          dimensions: dimensions,
          type: type
        }
          # query = Cloudinary::Uploader.upload(src_value)
          # @photos << {
          #   width: query["width"],
          #   height: query["height"],
          #   bytes: query["bytes"],
          #   url: query["url"]
          # }
      end
    end
    @photos.sort_by! { |photo| photo[:size] }
    @version.photos = @photos.reverse.first(3)
  end


  def create_version(website)
    url = website.url
    html_file = URI.open(url).read
    html_doc = Nokogiri::HTML(html_file)

    last_version = Version.find_by_website_id(@website.id)
    # if last_version && (Time.now.utc - last_version.created_at) < 86_400
    #   @version = last_version
    #   @version[:carbonapi_updated] = false
    #   carbon_infos = nil
    # else
      @version = Version.new
      carbon_infos = website_carbon_api(url)
      @version[:carbonapi_updated] = true
    # end

    fonts_and_backgrounds_scraping(html_doc)
    image_scraping(html_doc)

    background_color = @backgrounds.first(3)
    font_families = @font_families.first(3)
    if carbon_infos.nil?
      @version.update(all_images_size: @all_images_size, background_color: background_color, font_families: font_families )
    else
      @version.update(website_id: website.id, green_hosting: carbon_infos["green"], bytes: carbon_infos["bytes"], cleaner_than: carbon_infos["cleanerThan"], adjusted_bytes: carbon_infos["statistics"]["adjustedBytes"], energy: carbon_infos["statistics"]["energy"], co2: carbon_infos["statistics"]["co2"]["grid"]["grams"], co2_renewable: carbon_infos["statistics"]["co2"]["renewable"]["grams"], all_images_size: @all_images_size, background_color: background_color, font_families: font_families )
    end
  end
end
# make a stimulus with a loading screen that last three seconds and then use websocket to dynamically display fetched infos
