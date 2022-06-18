class PagesController < ApplicationController

  skip_before_action :authenticate_user!, only: [ :home, :show, :about, :howitworks ]

  def home
  @website = Website.new
  end

end
