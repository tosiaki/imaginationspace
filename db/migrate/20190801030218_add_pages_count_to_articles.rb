class AddPagesCountToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :pages_count, :integer, default: 0
  end
end
