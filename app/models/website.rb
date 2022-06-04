class Website < ApplicationRecord
  belongs_to :user
  has_many :versions, dependent: :destroy
  has_many_attached :photos, dependent: :destroy
  # validates_uniqueness_of :url, scope: :user
end
