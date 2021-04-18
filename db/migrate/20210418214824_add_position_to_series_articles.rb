class AddPositionToSeriesArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :series_articles, :position, :integer
  end
end
