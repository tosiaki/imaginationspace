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

  desc "Resume previous task that failed due to missed capitalization"
  task resume_transfer :environment do
    DrawingsConverter.new(Drawing.find(12), true) #Resume for id 12
    Drawing.where.not(id: 12).each do |drawing|
      DrawingsConverter.new(drawing)
    end
end
