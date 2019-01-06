namespace :fix_typos do
  desc "Fix the missing link that resulted from a typo in usage of Nokogiri"
  task image_link: :environment do
    Article.find_each do |article|
      article.pages.each do |page|
        page_content = Nokogiri::HTML.fragment(page.content)
        page_content.css("a").each do |anchor|
          if anchor.content.blank?
            anchor.content = "here"
            anchor.add_next_sibling " "
          end
        end
        page.update_attribute(:content, page_content.to_html)
      end
    end
  end

end
