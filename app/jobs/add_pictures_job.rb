class AddPicturesJob < ApplicationJob
  queue_as :default

  def perform(pictures:, page: nil, article: nil, page_number: nil, editing_password: nil)
    if page
      page.article.editing_password = editing_password
      pictures.each do |picture|
        add_picture_to_page(picture, page)
      end
      page.save
    else
      article.editing_password = editing_password
      pictures.each do |picture|
        page_number += 1
        page = article.pages.build(page_number: page_number, content: '')
        add_picture_to_page(picture, page)
        page.save
      end
    end
  end

  def add_picture_to_page(picture, page)
    new_picture = add_picture_object(picture, page)
    page.content = picture_content(new_picture) + page.content.html_safe
  end

  def add_picture_object(picture, page)
    new_picture = ShrinePicture.create(picture: picture)
    page.shrine_pictures << new_picture
    new_picture
  end

  def picture_content(picture_object)
    result = "\n\n" + ApplicationController.new.render_to_body(partial: 'article_pages/image_tag', locals: {picture: picture_object})
    result.html_safe
  end

end
