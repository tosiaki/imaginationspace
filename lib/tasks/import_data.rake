namespace :import_data do
  desc "Import all the data from the imaginationspace site"
  task imaginationspace: :environment do
    require_relative "../imaginationspace_importer"
    importer = ImaginationspaceImporter.new
    importer.import
  end

  task profile_pictures: :environment do
    mysql_db = ActiveRecord::Base.establish_connection(
      adapter: "mysql2",
      host: "localhost",
      username: "root",
      password: ENV['MYSQL_PASSWORD'],
      database: "pralic_is"
      ).connection
    users = mysql_db.select_all("SELECT * FROM user")

    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    users.each do |user|
      profile_picture_path = Rails.root.join('lib','tasks','legacy_i',user['username'],"profile.*")
      Dir[profile_picture_path].each do |filename|
        file = File.open(filename)
        new_user = User.find_by(email: user['email'].downcase)
        unless new_user.update(icon: file)
          debugger
        end
      end
    end
  end



end
