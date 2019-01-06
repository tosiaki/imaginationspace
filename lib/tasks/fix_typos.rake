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

  task restore_images: :environment do
    status_tag = ArticleTag.find_by(name: 'Status', context: "media")
    unformatted_html = Nokogiri::XML::Node::SaveOptions.class_eval { |m| m::DEFAULT_HTML ^ m::FORMAT }
    Article.find_each do |article|
      unless article.media == status_tag
        article.pages.each do |page|
          page_content = Nokogiri::HTML.fragment(page.content)
          first_div = page_content.css("div").first
          if first_div.content[0] == "\n"
            image_url = first_div.css("a").first.attributes["href"].value
            anchor_tag = Nokogiri::XML::Node.new "a", page_content
            anchor_tag['href'] = image_url
            img_tag = Nokogiri::XML::Node.new "img", page_content
            img_tag['src'] = image_url

            first_div.content = ""
            anchor_tag.parent = first_div
            img_tag.parent = anchor_tag
          end
          page.update_attribute(:content, page_content.to_html(save_with: unformatted_html))
        end
      end
    end
  end

end
