require "fastimage"
require "open-uri"
require "nokogiri"

class ImageScrapingJob < ApplicationJob
  queue_as :default

  def perform(version, website)
    # Do something later
    image_scraping(version, website)
  end
end

private
def image_scraping(version, website)
  html_file = URI.open(website.url).read
  html_doc = Nokogiri::HTML(html_file)
  @photos = []
  # Parallel.each(html_doc.search("img")) { |image|
  html_doc.search("img").each do |image|
    # added in code for lazy loading. If page has lazy loading, there won't be an image URL and it should be skipped.
    # e.g. nytimes.com
    # if image.attributes["loading"] exists and has a value (e.g. "lazy"), we can't scrape that image.
    # so don't include it. hence the unless.
    unless image.attributes["alt"].nil? || image.attributes["loading"]
      src_value = image.attributes["data-src"] ? image.attributes["data-src"].value : image.attributes["src"].value
      if src_value.start_with?("http")
      else
        src_value.insert(0, website.url)
      end
      dimensions = FastImage.size(src_value)
      if dimensions
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
  end
  #}
  @photos.sort_by! { |photo| photo[:size] }
  version.update(photos: @photos.reverse.first(3))
  # some sites e.g. websitecarbon.com return an empty array for @photos, because of the way photos are displayed.
  # if this happens, assign scraped_succssfully as false, which will cause them to be redirected to scraping error page.
  if version.photos == []
    @scraped_successfully = false
  end
end
