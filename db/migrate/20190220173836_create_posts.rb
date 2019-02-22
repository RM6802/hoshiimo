class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :price
      t.boolean :purchased, null: false, default: false
      t.datetime :posted_at, null: false
      t.datetime :purchased_at, dafault: false

      t.timestamps
    end

    add_index :posts, :name
  end
end
