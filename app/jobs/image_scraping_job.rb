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
      link = control_link_validity(src_value)

      dimensions = FastImage.size(link)
      if dimensions
        type = FastImage.type(link)
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

  main_photos = sort_mains(@photos)
  version.update(photos: main_photos)
end


def control_link_validity(link)
  link.start_with?("http") ? link : link.insert(0, @website.url)
end

def sort_mains(array)
  sorted_array = array.sort_by { |element| array.count(element) }.reverse.uniq
  return sorted_array.first(3)
end
