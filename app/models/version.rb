class Version < ApplicationRecord
  belongs_to :website
  # has_many_attached :photos, dependent: :destroy
end
