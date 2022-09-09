class FontsBackgroundsScrapingJob < ApplicationJob
  queue_as :default

  def perform(version, website)

    html_file = URI.open(website.url).read
    html_doc = Nokogiri::HTML(html_file)

    stylesheets = stylesheets_scraping(html_doc, website)
    fonts_and_backgrounds_scraping(stylesheets)

    version.update(background_color: @main_background_colors, font_families: @main_font_families )
  end
end

private

def stylesheets_scraping(html_doc, website)
  stylesheets = []

  html_doc.search("link").each do |link|
    stylesheets << link.attributes["href"].value if link.attributes["rel"].value == "stylesheet"
  end
  # removed the part that corrected the stylesheet url, seemed to have no purpose, check with Brendan
  return stylesheets
end


def fonts_and_backgrounds_scraping(stylesheets)

  stylesheets.each do |stylesheet|
    style_file = URI.open(stylesheet).read

    @font_families = style_file.scan(/font-family: ?['"]?([\w*[\s-]?]*)/).flatten
    @backgrounds = style_file.scan(/background[-color]*:([#]?\w{1,16});[. ]?/).flatten
  end

  remove_duplicate_colors(@backgrounds) unless @backgrounds.nil?

  @main_background_colors = sort_mains(@backgrounds)
  @main_font_families = sort_mains(@font_families)
end

def remove_duplicate_colors(backgrounds)
    backgrounds.map! do |color|
    white_colors = ["white", "#ffffff"]
    if white_colors.include?(color)
      color = "#fff"
    else
      color = color
    end
  end
  backgrounds.reject! { |color| color == "transparent" }
  return backgrounds
end

def sort_mains(array)
  print "ARRAY"
  print array
  sorted_array = array.sort_by { |element| array.count(element) }.reverse.uniq
  return sorted_array.first(3)
end
