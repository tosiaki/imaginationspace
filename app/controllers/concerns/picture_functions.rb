module Concerns::PictureFunctions
  extend ActiveSupport::Concern

  def add_picture_to_page(picture, article, page_number)
    article_picture = ArticlePicture.create(picture: picture)
    article.append(content: render_to_body(partial: 'article_pages/image_tag', locals: {picture: article_picture}).html_safe, page_number: page_number)
  end
end