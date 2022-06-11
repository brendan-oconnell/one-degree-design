class AddFontFamiliesToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :font_families, :string
  end
end
