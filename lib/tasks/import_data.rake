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

  task switch_store: :environment do
    unformatted_html ||= Nokogiri::XML::Node::SaveOptions.class_eval { |m| m::DEFAULT_HTML ^ m::FORMAT }
    Page.find_each do |page|
      page_content = Nokogiri::HTML.fragment(page.content)
      page_content.css('img').each do |image_tag|
        if image_tag.attributes["src"].value =~ /tosiaki.s3.us-east-2.amazonaws.com\/new_legacy\//
          puts "Match found: #{page.content}"
          attacher = page.shrine_pictures.first.picture_attacher
          uploaded_file = attacher.store!(page.shrine_pictures.first.picture)
          attacher.swap(uploaded_file)
          image_tag.attributes["src"].value = uploaded_file[:original].url
          page_content.css('a').each do |anchor_tag|
            anchor_tag.attributes["href"].value = uploaded_file[:original].url
          end
          page.update_attribute(:content, page_content.to_html(save_with: unformatted_html))
        end
      end
    end
  end
end
