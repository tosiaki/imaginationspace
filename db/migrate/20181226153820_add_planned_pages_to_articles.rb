class AddPlannedPagesToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :planned_pages, :integer, default: 1
  end
end
