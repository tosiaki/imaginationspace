class Page < ApplicationRecord
  belongs_to :article, inverse_of: :pages
  default_scope -> { order(page_number: :asc) }

  before_create :make_room

  def display_title
    @title ||= title.present? ? title : "Page #{page_number}"
  end

  def append(addition)
    update(content: content+addition)
  end

  def move_up
    article.make_room_at_page(page_number+1)
    increment!(:page_number)
  end

  def make_room
    article.make_room_at_page(page_number)
  end
end
