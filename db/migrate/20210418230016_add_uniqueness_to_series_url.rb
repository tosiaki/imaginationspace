class AddUniquenessToSeriesUrl < ActiveRecord::Migration[6.1]
  def change
    add_index :series, [:url], unique: true
  end
end
