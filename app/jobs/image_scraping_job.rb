require "fastimage"
require "open-uri"
require "nokogiri"

class ImageScrapingJob < ApplicationJob
  queue_as :default

  def perform(version, website)

    html_file = URI.open(website.url).read
    html_doc = Nokogiri::HTML(html_file)

    image_scraping(version, html_doc)
  end
end

private


def image_scraping(version, html_doc)

  @photos = []

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

      end
    end
  end

  main_photos = @photos.sort_by! { |photo| photo[:size] }.reverse.first(3)
  version.update(photos: main_photos)

end
