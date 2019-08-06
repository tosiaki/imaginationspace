module Concerns::PictureFunctions
  extend ActiveSupport::Concern

  def add_picture_object(picture, page, inline_picture = false)
    new_picture = ShrinePicture.create(picture: picture, inline_picture: inline_picture)
    page.shrine_pictures << new_picture
    new_picture
  end

  def add_pictures_to_article(pictures, article, page, new_pages)
    page_number = page.page_number

    add_picture_to_page(pictures[0], page)
    @other_pictures = pictures.drop(1)

    if @other_pictures
      @other_pictures.each do |picture|
        if new_pages == '1'
          page_number += 1
          AddPicturesJob.perform_later(picture: picture, article: article, page_number: page_number)
        else
          AddPicturesJob.perform_later(picture: picture, page: page)
        end
      end
    end

    page
  end

  def add_picture_to_page(picture, page)
    new_picture = add_picture_object(picture, page)
    page.content = picture_content(new_picture) + page.content
  end

  def add_picture_to_signal_boost(picture, signal_boost)
    new_picture = add_picture_object(picture, signal_boost)
    signal_boost.comment = picture_content(new_picture) + signal_boost.comment
  end

  def picture_content(picture_object)
    result = render_to_body(partial: 'article_pages/image_tag', locals: {picture: picture_object})
    # result += "\n\n" + render_to_body(partial: 'article_pages/image_note', locals: {picture: picture_object}) if picture_object.picture[:original].width > 1200 || picture_object.picture[:original].height > 2000
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