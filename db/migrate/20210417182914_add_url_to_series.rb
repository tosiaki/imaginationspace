class AddUrlToSeries < ActiveRecord::Migration[5.2]
  def change
    add_column :series, :url, :string
  end
end
