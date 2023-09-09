require "fastimage"
require "open-uri"
require "nokogiri"

class ImageScrapingJob < ApplicationJob
  queue_as :default

  def perform(version, website)

    html_file = URI.open(website.url).read
    html_doc = Nokogiri::HTML(html_file)

    image_scraping(version, html_doc, website.url)
  end
end

private


def image_scraping(version, html_doc, url)

  @photos = []

  html_doc.search("img").each do |image|
    # if page has lazy loading, there won't be an image URL and it should be skipped.
    # e.g. nytimes.com
    # if image.attributes["loading"] exists and has a value (e.g. "lazy"), we can't scrape that image.
    # so don't include it.
    unless image.attributes["alt"].nil? || image.attributes["loading"]
      src_value = image.attributes["data-src"] ? image.attributes["data-src"].value : image.attributes["src"].value
      link = control_link_validity(src_value, url)
      # https://rubygems.org/gems/fastimage/versions/2.2.5
      # approximates image size by quickly grabbing dimensions
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

  main_photos = sort_main_photos(@photos)
  version.update(photos: main_photos)
end


def control_link_validity(link, web_url)
  link.start_with?("http") ? link : link.insert(0, web_url)
end

def sort_main_photos(photos)
  sorted_photos = photos.sort_by { |photo| photo[:size] }.reverse.uniq
  return sorted_photos.first(3)
end
