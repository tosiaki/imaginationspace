class AddPageNumberToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :page_number, :integer, default: 1
  end
end
