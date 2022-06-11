class VersionsController < ApplicationController

  def show
    @version = Version.find(params[:id])
    @version.font_families = JSON.parse(@version.font_families)
  end
end
