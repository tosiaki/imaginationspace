class CreateSeriesArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :series_articles do |t|
      t.references :series, foreign_key: true
      t.references :article, foreign_key: true

      t.timestamps
    end
  end
end
