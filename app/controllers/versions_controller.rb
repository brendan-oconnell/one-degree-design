class VersionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @version = Version.find(params[:id])
  end
end
