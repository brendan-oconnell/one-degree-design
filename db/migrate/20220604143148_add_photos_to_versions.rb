class AddPhotosToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :photos, :text
  end
end
