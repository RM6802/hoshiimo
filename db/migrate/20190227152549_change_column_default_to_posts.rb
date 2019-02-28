class ChangeColumnDefaultToPosts < ActiveRecord::Migration[5.2]
  def up
    change_column_default :posts, :purchased_at, nil
  end

  def down
    change_column_default :posts, :purchased_at, false
  end
end
