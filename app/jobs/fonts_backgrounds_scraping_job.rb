class FontsBackgroundsScrapingJob < ApplicationJob
  queue_as :urgent

  def perform(html_doc, version, website)
    # Do something later
    fonts_and_backgrounds_scraping(@arguments[0], version, website)
  end
end

private

def fonts_and_backgrounds_scraping(html_doc, version, website)
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
