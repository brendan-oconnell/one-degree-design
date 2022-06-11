class AddCo2RenewableToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :co2_renewable, :float

  end
end
