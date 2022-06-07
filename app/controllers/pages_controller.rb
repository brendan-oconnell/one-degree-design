class PagesController < ApplicationController

  skip_before_action :authenticate_user!, only: [ :home, :show, :about, :howitworks ]

  def home
  end

  def show
  end
end
