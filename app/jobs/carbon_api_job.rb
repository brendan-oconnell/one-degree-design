class CarbonApiJob < ApplicationJob
  queue_as :urgent

  def perform(url, version)
    # Do something later
    website_carbon_api(@arguments[0], version)
  end
end

private

def website_carbon_api(url, version)
  # make a new version only if last version has been made more than 24 horus ago
  carbonurl = "https://api.websitecarbon.com/site?url=#{url}"
  carbon = URI.open(carbonurl).read
  carbon_infos = JSON.parse(carbon)
  version.update(green_hosting: carbon_infos["green"], bytes: carbon_infos["bytes"], cleaner_than: carbon_infos["cleanerThan"], adjusted_bytes: carbon_infos["statistics"]["adjustedBytes"], energy: carbon_infos["statistics"]["energy"], co2: carbon_infos["statistics"]["co2"]["grid"]["grams"], co2_renewable: carbon_infos["statistics"]["co2"]["renewable"]["grams"])
end
