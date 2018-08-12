namespace :reprocess_all_images do
  desc "Resize the page view image and add dimensions to all images"
  task reprocess_images: :environment do
    [ComicPage, Drawing].each do |image_class|
      image_class.all.each do |drawing|
        drawing.drawing.recreate_versions!
        if drawing.drawing._storage.to_s == "CarrierWave::Storage::File"
          image_url = drawing.drawing.current_path
        elsif drawing.drawing._storage.to_s == "CarrierWave::Storage::Fog"
          image_url = drawing.drawing.url
        end
        drawing.width, drawing.height = ::MiniMagick::Image.open(image_url)[:dimensions]
        drawing.save
      end
    end
  end
end
