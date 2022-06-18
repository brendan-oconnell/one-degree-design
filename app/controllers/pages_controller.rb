class PagesController < ApplicationController

  skip_before_action :authenticate_user!, only: [ :home, :show, :about, :howitworks ]

  def home
  @website = Website.new
  end

  def dashboard
    @user = current_user
    @websitenew = Website.new
    @website = Website.find_by_user_id(@user.id)
    @websites = Website.where(user_id: @user)

  end
end
