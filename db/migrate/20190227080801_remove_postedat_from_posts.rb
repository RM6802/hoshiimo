class RemovePostedatFromPosts < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :posted_at
  end
end
