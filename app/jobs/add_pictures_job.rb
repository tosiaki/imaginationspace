class AddPicturesJob < ApplicationJob
  queue_as :default

  def perform(picture:, page: nil, article: nil, page_number: nil)
    page ||= article.pages.build(page_number: page_number, content: '')
    add_picture_to_page(picture, page)
    page.save
  end

  def add_picture_to_page(picture, page)
    new_picture = add_picture_object(picture, page)
    page.content = page.content + picture_content(new_picture)
  end

  def add_picture_object(picture, page)
    new_picture = ShrinePicture.create(picture: picture)
    page.shrine_pictures << new_picture
    new_picture
  end

  def picture_content(picture_object)
    result = "\n\n" + ApplicationController.new.render_to_body(partial: 'article_pages/image_tag', locals: {picture: picture_object})
    result += "\n\n" + ApplicationController.new.render_to_body(partial: 'article_pages/image_note', locals: {picture: picture_object}) if picture_object.picture[:original].width > 1200 || picture_object.picture[:original].height > 2000
    result.html_safe
  end

end
