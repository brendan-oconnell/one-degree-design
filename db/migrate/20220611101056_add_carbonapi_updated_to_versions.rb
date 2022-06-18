class AddCarbonapiUpdatedToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :carbonapi_updated, :boolean
  end
end
