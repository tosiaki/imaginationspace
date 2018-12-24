class AddCountsToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :kudos_count, :integer, default: 0
    add_column :articles, :signal_boosts_count, :integer, default: 0
  end
end
