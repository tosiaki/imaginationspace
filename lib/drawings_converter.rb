require_relative 'works_converter'
class DrawingsConverter < WorksConverter
  def create_article
    @status = Status.new(
      user: @work.user,
      created_at: @work.created_at,
      updated_at: @work.updated_at,
      timeline_time: @work.updated_at
      )
    @article = Article.new(
      title: @work.title,
      description: @work.caption,
      planned_pages: 1,
      max_pages: 1,
      created_at: @work.created_at,
      updated_at: @work.updated_at,
      status: @status,
      )

    doc = convert_drawing_page(@work)
    @article.pages.build(
      content: doc.to_html(save_with: unformatted_html),
      created_at: @work.created_at,
      updated_at: @work.updated_at,
      page_number: 1
      )

    @status.save
  end
end