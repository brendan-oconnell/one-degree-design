class CreateWebsites < ActiveRecord::Migration[6.1]
  def change
    create_table :websites do |t|
      t.string :url
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
