class Website < ApplicationRecord
  belongs_to :user
  has_many :versions
  # validates_uniqueness_of :url, scope: :user
end
