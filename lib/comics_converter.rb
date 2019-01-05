require_relative 'works_converter'
class ComicsConverter < WorksConverter
  def create_article
    @status = Status.new(
      user: @work.user,
      created_at: @work.created_at,
      updated_at: @work.updated_at,
      timeline_time: @work.page_addition
      )
    @article = Article.new(
      title: @work.title,
      description: @work.description,
      planned_pages: @work.pages,
      max_pages: @work.comic_pages.count,
      created_at: @work.created_at,
      updated_at: @work.updated_at,
      status: @status
      )
    convert_pages
    @article.save
  end

  def convert_pages
    @work.comic_pages.each do |comic_page|
      doc = convert_drawing_page(comic_page)

      @article.pages.build(
        content: doc.to_html(save_with: unformatted_html),
        created_at: comic_page.created_at,
        updated_at: comic_page.updated_at,
        page_number: comic_page.page,
        )
    end
  end
end