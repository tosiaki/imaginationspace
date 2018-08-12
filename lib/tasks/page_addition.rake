namespace :page_addition do
  desc "Initialize the max pages and page addition fields"
  task initialize_values: :environment do
    Comic.all.each do |c|
      c.update_attribute(:max_pages, c.comic_pages.map(&:page).max)
      c.update_attribute(:page_addition, c.created_at)
    end
  end

end
