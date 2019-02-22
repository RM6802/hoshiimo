class AddPublishedToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :published, :boolean, null: false, default: false
  end
end
