class FontsBackgroundsScrapingJob < ApplicationJob
  queue_as :default

  def perform(version, website)

    fonts_and_backgrounds_scraping(version, website)
  end
end

private

def fonts_and_backgrounds_scraping(version, website)
  html_file = URI.open(website.url).read
  html_doc = Nokogiri::HTML(html_file)
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
      modified_stylesheet_url = stylesheet.insert(0, website.url)
      stylesheet_corrected_links << modified_stylesheet_url
    end
  end



  @font_families = []
  @backgrounds = []

  stylesheet_corrected_links.each do |stylesheet|
    style_file = URI.open(stylesheet).read

    @font_families << style_file.scan(/font-family:\s?'?"?(\w*[- ]?\w*[- ]?\w*)[",'!;]?/)
    @backgrounds << style_file.scan(/background[-color]*:([#]?\w{1,16});[. ]?/)
  end
  @font_families.flatten!.map! { |font| font.downcase.gsub(/['"]/, "") }
  @backgrounds.flatten!

  # REFACTO NEEDED!
  @font_families.reject! { |font| font == " "}
  @font_families.reject! { |font| font == "var"}
  @font_families.reject! { |font| font == "inherit"}
  @backgrounds.reject! { |color| color == "initial"}

  @backgrounds.map! do |color|
    white_colors = ["white", "#ffffff"]
    if white_colors.include?(color)
      color = "#fff"
    else
      color = color
    end
  end
  @backgrounds.reject! { |color| color == "transparent" }



  @font_families.sort_by! { |font| @font_families.count(font) }.reverse!.uniq!
  @backgrounds.sort_by! { |color| @backgrounds.count(color) }.reverse!.uniq!
  background_color = @backgrounds.first(3)
  font_families = @font_families.first(3)
  version.update(background_color: background_color, font_families: font_families )
end
