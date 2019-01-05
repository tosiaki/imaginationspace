module Concerns::PictureFunctions
  extend ActiveSupport::Concern

  def add_picture_object(picture, page, inline_picture = false)
    new_picture = ShrinePicture.create(picture: picture, inline_picture: inline_picture)
    page.shrine_pictures << new_picture
    new_picture
  end

  def add_pictures_to_article(pictures, article, page, new_pages)
    page_number = page.page_number
    if pictures
      pictures.each_with_index do |picture, index|
        if index > 0 && new_pages
          page_number += 1
          page = article.pages.build(page_number: page_number, content: '')
        end
        add_picture_to_page(picture, page)
      end
    end
    page
  end

  def add_picture_to_page(picture, page)
    new_picture = add_picture_object(picture, page)
    page.content = page.content + picture_content(new_picture)
  end

  def add_picture_to_signal_boost(picture, signal_boost)
    new_picture = add_picture_object(picture, signal_boost)
    signal_boost.comment = signal_boost.comment + picture_content(new_picture)
  end

  def picture_content(picture_object)
    result = "\n\n" + render_to_body(partial: 'article_pages/image_tag', locals: {picture: picture_object})
    result += "\n\n" + render_to_body(partial: 'article_pages/image_note', locals: {picture: picture_object}) if picture_object.picture[:original].width > 1200 || picture_object.picture[:original].height > 2000
    result.html_safe
  end

  def process_inline_uploads(page)
    page_content = Nokogiri::HTML.fragment(page.content)
    page_content.css('img').each do |image_tag|
      if (file_data = image_tag['data-file-data'])
        new_picture = add_picture_object(file_data, page, true)
        image_tag.attributes["src"].value = new_picture.picture[:original].url
        image_tag.remove_attribute "data-file-data"
      end
    end
    unformatted_html = Nokogiri::XML::Node::SaveOptions.class_eval { |m| m::DEFAULT_HTML ^ m::FORMAT }
    page_content.to_html(save_with: unformatted_html)
  end
end