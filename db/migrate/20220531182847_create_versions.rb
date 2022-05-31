class CreateVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :versions do |t|
      t.references :website, null: false, foreign_key: true
      t.boolean :green_hosting
      t.float :bytes
      t.float :cleaner_than
      t.float :adjusted_bytes
      t.string :energy
      t.float :co2
      t.float :all_images_size
      t.float :fonts_file_size
      t.string :background_color

      t.timestamps
    end
  end
end
