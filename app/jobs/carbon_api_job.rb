class CarbonApiJob < ApplicationJob
  queue_as :default

  def perform(url, version)
    website_url = @arguments[0]
    website_carbon_api(website_url, version)
  end
end

private

def website_carbon_api(website_url, version)
  carbon_api_url = "https://api.websitecarbon.com/site?url=#{website_url}"
  carbon_data = URI.open(carbon_api_url).read
  carbon_infos = JSON.parse(carbon_data)

  version.update(green_hosting: carbon_infos["green"], bytes: carbon_infos["bytes"], cleaner_than: carbon_infos["cleanerThan"], adjusted_bytes: carbon_infos["statistics"]["adjustedBytes"], energy: carbon_infos["statistics"]["energy"], co2: carbon_infos["statistics"]["co2"]["grid"]["grams"], co2_renewable: carbon_infos["statistics"]["co2"]["renewable"]["grams"])
end
