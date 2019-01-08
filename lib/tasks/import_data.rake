namespace :import_data do
  desc "Import all the data from the imaginationspace site"
  task imaginationspace: :environment do
    require_relative "../imaginationspace_importer"
    importer = ImaginationspaceImporter.new
    importer.import
  end

end
