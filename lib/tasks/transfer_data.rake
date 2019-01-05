namespace :transfer_data do
  require_relative '../comics_converter'
  require_relative '../drawings_converter'

  desc "Transfer all data on the current site to the new system"
  task current_site: :environment do
    Comic.all.each do |comic|
      ComicsConverter.new(comic)
    end

    Drawing.all.each do |drawing|
      DrawingsConverter.new(drawing)
    end
  end

end
