class CloudinaryCallJob < ApplicationJob
  queue_as :default

  def perform(version)
    @version = version
    @website = Website.find(@version.website_id)
    url = @version.website.url
    html_file = URI.open(url).read
    html_doc = Nokogiri::HTML(html_file)

    compile_photos_with_cloudinary(html_doc)
  end
end

private

def compile_photos_with_cloudinary(html_doc)
  last_version = Version.find_by_website_id(@website.id)
  # temp 24hours is too long
  if (Time.now.utc - last_version.created_at) < 86_400 && (Time.now.utc - last_version.created_at) > 3000
    @photos = @version.photos
  else
    @photos = []
    html_doc.search("img").each do |image|
      # @photos << image.attributes["src"].value unless image.attributes["alt"].nil?
      unless image.attributes["alt"].nil?
        src_value = image.attributes["data-src"] ? image.attributes["data-src"].value : image.attributes["src"].value

        query = Cloudinary::Uploader.upload(src_value)
        @photos << {
          width: query["width"],
          height: query["height"],
          bytes: query["bytes"],
          url: query["url"]
        }
      end
    end
  end
    @photos.sort_by! { |photo| photo[:bytes] }
    @version.photos = @photos.reverse.first(3)

    # photos_size
    @all_images_size = 0
    @photos.each { |photo| @all_images_size += photo[:bytes] }

    @version.update(all_images_size: @all_images_size)
    @version.save
end
