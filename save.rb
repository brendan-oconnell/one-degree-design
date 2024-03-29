 # def website_carbon_api(url)
  #   # make a new version only if last version has been made more than 24 horus ago
  #   carbonurl = "https://api.websitecarbon.com/site?url=#{url}"
  #   carbon = URI.open(carbonurl).read
  #   carbon_infos = JSON.parse(carbon)
  # end

  # def fonts_and_backgrounds_scraping(html_doc)
  #   stylesheet_links = []
  #   stylesheet_corrected_links = []
  #   # add all stylesheets to array
  #   html_doc.search("link").each do |link|
  #     stylesheet_links << link.attributes["href"].value if link.attributes["rel"].value == "stylesheet"
  #   end
  #   # if stylesheet begins with https://www, don't do anything with it.
  #   stylesheet_links.each do |stylesheet|
  #     if stylesheet.start_with?("http")
  #       stylesheet_corrected_links << stylesheet
  #     else
  #       modified_stylesheet_url = stylesheet.insert(0, @website.url)
  #       stylesheet_corrected_links << modified_stylesheet_url
  #     end
  #   end

  #   # TODO:

  #   @font_families = []
  #   @backgrounds = []

  #   stylesheet_corrected_links.each do |stylesheet|
  #     style_file = URI.open(stylesheet).read

  #     @font_families << style_file.scan(/font-family:[",'](.{1,22})[",']/)
  #     @backgrounds << style_file.scan(/background[-color]*:(\S{1,16});/)
  #   end
  #   @font_families.flatten!.map! { |font| font.downcase.gsub(/['"]/, "") }
  #   @backgrounds.flatten!

  #   # if his font is not downloaded applaud
  #   default_font_families = ["open sans", "times", "times new roman", "georgia", "serif", "Verdana", "Arial", "Helvetica", "sans-serif", "courier", "monospace", "lucida console", "cursive", "fantasy" ]

  #   @font_families.reject! { |font| default_font_families.include?(font.downcase) }
  #   @backgrounds.map! do |color|
  #     white_colors = ["white", "#ffffff"]
  #     if white_colors.include?(color)
  #       color = "#fff"
  #     else
  #       color = color
  #     end
  #   end
  #   @backgrounds.reject! { |color| color == "transparent" }



  #   @font_families.sort_by! { |font| @font_families.count(font) }.reverse!.uniq!
  #   @backgrounds.sort_by! { |color| @backgrounds.count(color) }.reverse!.uniq!
  # end


  # def image_scraping(html_doc)
  #   @photos = []
  #   html_doc.search("img").each do |image|
  #     # added in code for lazy loading. If page has lazy loading, there won't be an image URL and it should be skipped.
  #     # e.g. nytimes.com
  #     # if image.attributes["loading"] exists and has a value (e.g. "lazy"), we can't scrape that image.
  #     # so don't include it. hence the unless.
  #     unless image.attributes["alt"].nil? || image.attributes["loading"]
  #       src_value = image.attributes["data-src"] ? image.attributes["data-src"].value : image.attributes["src"].value
  #       if src_value.start_with?("http")
  #       else
  #         src_value.insert(0, @website.url)
  #       end
  #       dimensions = FastImage.size(src_value)
  #       if dimensions
  #         type = FastImage.type(src_value)
  #         size = dimensions[0] * dimensions[1]
  #         @photos << {
  #           url: src_value,
  #           size: size,
  #           dimensions: dimensions,
  #           type: type
  #         }
  #           # query = Cloudinary::Uploader.upload(src_value)
  #           # @photos << {
  #           #   width: query["width"],
  #           #   height: query["height"],
  #           #   bytes: query["bytes"],
  #           #   url: query["url"]
  #           # }
  #       end
  #     end
  #   end
  #   @photos.sort_by! { |photo| photo[:size] }
  #   @version.photos = @photos.reverse.first(3)
  #   # some sites e.g. websitecarbon.com return an empty array for @photos, because of the way photos are displayed.
  #   # if this happens, assign scraped_succssfully as false, which will cause them to be redirected to scraping error page.

  #   if @version.photos == []
  #     @scraped_successfully = false
  #   end
  # end



  # websites controller pre 9/9/22

#   require "json"

# class WebsitesController < ApplicationController


#   def create
#     existing_website = Website.find_by_url("https://www.#{website_params[:url]}")
#     if Website.find_by_url("https://www.#{website_params[:url]}") && existing_website.user == current_or_guest_user
#       @website = Website.find_by_url("https://www.#{website_params[:url]}")
#     else
#       @website = Website.new(website_params)
#       @website.url = "https://www.#{website_params[:url]}"
#       @website.user = current_or_guest_user unless current_or_guest_user.nil?
#     end

#     if @website.valid?
#       @website.save
#       create_version(@website)
#       if @scraped_successfully == true
#         @version.save
#         # Switched cloudinary to fast-image because of runtime
#           # CloudinaryCallJob.perform_later(@version)
#         redirect_to version_path(@version)
#       else
#         @version.destroy
#         redirect_to scrapingerror_path
#       end
#     else
#       @version.destroy
#       redirect_to scrapingerror_path
#     end
#   end

#   private

#   def website_params
#     params.require(:website).permit(:url, :user, photos: [])
#   end




#   def create_version(website)
#     @scraped_successfully = true
#     url = website.url
#     last_version = Version.find_by_website_id(@website.id)

#     reuse_recent_version(last_version)
#     # @version = Version.new
#     # @version.update(website_id: website.id)

#     FontsBackgroundsScrapingJob.perform_later(@version, @website)
#     ImageScrapingJob.perform_later(@version, @website)
#     CarbonApiJob.perform_later(url, @version)

#     sleep 20

#   end

#   def reuse_recent_version(last_version)
#     if last_version && (Time.now.utc - last_version.created_at) < 86_400
#       @version = last_version
#       @version[:carbonapi_updated] = false
#       carbon_infos = nil
#     else
#       @version = Version.new
#       @version.update(website_id: website.id)
#       carbon_infos = website_carbon_api(url)
#       @version[:carbonapi_updated] = true
#     end
#   end

# end


# pre 9/9/22 font scraping

# class FontsBackgroundsScrapingJob < ApplicationJob
#   queue_as :default

#   def perform(version, website)
#     fonts_and_backgrounds_scraping(version, website)
#   end
# end

# private

# def fonts_and_backgrounds_scraping(version, website)
#   html_file = URI.open(website.url).read
#   html_doc = Nokogiri::HTML(html_file)
#   stylesheet_links = []
#   stylesheet_corrected_links = []
#   # add all stylesheets to array
#   html_doc.search("link").each do |link|
#     stylesheet_links << link.attributes["href"].value if link.attributes["rel"].value == "stylesheet"
#   end
#   # if stylesheet begins with https://www, don't do anything with it.
#   stylesheet_links.each do |stylesheet|
#     if stylesheet.start_with?("http")
#       stylesheet_corrected_links << stylesheet
#     else
#       modified_stylesheet_url = stylesheet.insert(0, website.url)
#       stylesheet_corrected_links << modified_stylesheet_url
#     end
#   end



#   @font_families = []
#   @backgrounds = []

#   stylesheet_corrected_links.each do |stylesheet|
#     style_file = URI.open(stylesheet).read

#     @font_families << style_file.scan(/font-family: ?([\w*[\s-]?]*)[,'";]?/)
#     @backgrounds << style_file.scan(/background[-color]*:([#]?\w{1,16});[. ]?/)
#   end
#   @font_families.flatten!.map! { |font| font.downcase.gsub(/['"]/, "") }
#   @backgrounds.flatten!


#   @backgrounds.map! do |color|
#     white_colors = ["white", "#ffffff"]
#     if white_colors.include?(color)
#       color = "#fff"
#     else
#       color = color
#     end
#   end
#   @backgrounds.reject! { |color| color == "transparent" }



#   @font_families.sort_by! { |font| @font_families.count(font) }.reverse!.uniq!
#   @backgrounds.sort_by! { |color| @backgrounds.count(color) }.reverse!.uniq!
#   background_color = @backgrounds.first(3)
#   font_families = @font_families.first(3)
#   version.update(background_color: background_color, font_families: font_families )
# end


# stylesheet_sraping

# def stylesheets_scraping(html_doc, website)
#   stylesheet_links = []
#   stylesheet_corrected_links = []

#   html_doc.search("link").each do |link|
#     stylesheet_links << link.attributes["href"].value if link.attributes["rel"].value == "stylesheet"
#   end

#   stylesheet_links.each do |stylesheet|
#     if stylesheet.start_with?("http")
#       stylesheet_corrected_links << stylesheet
#     else
#       @modified_stylesheet_url = stylesheet.insert(0, website.url)
#       stylesheet_corrected_links << @modified_stylesheet_url
#       puts "HERE IS THE BUG"
#     end
#   end
#   return stylesheet_corrected_links
# end
