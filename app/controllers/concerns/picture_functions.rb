module Concerns::PictureFunctions
  extend ActiveSupport::Concern

  def picture_object(picture)
    ShrinePicture.create(picture: picture)
  end

  def add_picture_to_article(picture, article, page_number)
    article.append(content: picture_content(picture_object(picture)), page_number: page_number)
  end

  def add_picture_to_page(picture, page)
    page.append(picture_content(picture_object(picture)))
  end

  def add_picture_to_signal_boost(picture, signal_boost)
    signal_boost.append(picture_content(picture_object(picture)))
  end

  def picture_content(picture_object)
    result = "\n\n" + render_to_body(partial: 'article_pages/image_tag', locals: {picture: picture_object})
    result += "\n\n" + render_to_body(partial: 'article_pages/image_note', locals: {picture: picture_object}) if picture_object.picture[:original].width > 1200 || picture_object.picture[:original].height > 2000
    result.html_safe
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
end