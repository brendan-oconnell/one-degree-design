class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :about, :howitworks ]

  def home
  end
end
