class PagesController < ApplicationController

  # skip_before_action :authenticate_user!, only: [ :home, :websites, :versions, :about, :howitworks ]

  def home
  @website = Website.new
  end

  def dashboard
    @user = current_or_guest_user
    @websitenew = Website.new
    @website = Website.find_by_user_id(@user.id)
    if params[:query].present?
      @websites = Website.where(url: "https://www.#{params[:query]}")
    else
      @websites = Website.where(user_id: @user)

    end
  end
end
