class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.string :name
      t.text :image_text
      t.text :tags
      t.text :s3_url

      t.timestamps
    end
  end
end
