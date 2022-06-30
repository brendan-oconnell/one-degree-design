class Website < ApplicationRecord
  # validates :url, presence: true, format: { with: /(https):\/\/w{3}[.][a-z]+/, message: 'Please add a valid URL'}, on: :create
  belongs_to :user
  has_many :versions, dependent: :destroy
  has_many_attached :photos, dependent: :destroy
  # validates_uniqueness_of :url, scope: :user
end
