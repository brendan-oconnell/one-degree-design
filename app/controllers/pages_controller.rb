class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  @website = Website.new
  end

end
