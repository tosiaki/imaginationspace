namespace :transfer_data do
  require_relative '../comics_converter'
  require_relative '../drawings_converter'

  desc "Transfer comics"
  task transfer_comics: :environment do
    Comic.all.each do |comic|
      ComicsConverter.new(comic)
    end
  end

  desc "Transfer drawings"
  task transfer_drawings: :environment do
    Drawing.all.each do |drawing|
      DrawingsConverter.new(drawing)
    end
  end

end
