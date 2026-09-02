require "test_helper"

class AccountArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Users::SessionsController::LOGIN_RATE_LIMIT_STORE.clear
  end

  def log_in(user)
    post login_path, params: {
      user: { email: user.email, password: "password" }
    }
    follow_redirect!
  end

  def insert_articles(user, count, title_prefix: "Article")
    now = Time.current
    rows = count.times.map do |index|
      {
        title: "#{title_prefix} #{index + 1}", pages_count: index + 1,
        max_pages: index + 1, planned_pages: index + 1,
        created_at: now, updated_at: now
      }
    end
    ids = Article.insert_all!(rows, returning: %w[id]).rows.flatten
    ids.each { |id| Article.where(id: id).update_all(thread_id: id) }
    Page.insert_all!(ids.map do |id|
      {
        article_id: id, page_number: 1, content: "Page content",
        created_at: now, updated_at: now
      }
    end)
    Status.insert_all!(ids.map do |id|
      {
        user_id: user.id, post_type: "Article", post_id: id,
        timeline_time: now, created_at: now, updated_at: now
      }
    end)
    ids
  end

  test "requires authentication without loading content" do
    queries = count_database_queries { post account_articles_path }

    assert_redirected_to login_path
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_empty queries
  end

  test "does not expose the management listing through a plain GET" do
    queries = count_database_queries { get account_articles_path }

    assert_redirected_to "https://discord.gg/e97QGEA"
    assert_equal "public, max-age=86400", response.headers["Cache-Control"]
    assert_empty queries
  end

  test "lists only the current user's articles in one bounded query" do
    own_ids = insert_articles(users(:one), 2, title_prefix: "Mine")
    other_ids = insert_articles(users(:two), 1, title_prefix: "Not mine")
    log_in users(:one)

    queries = count_database_queries { post account_articles_path }

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
    assert_select "li[data-article-id]", count: 2
    own_ids.each { |id| assert_select %(li[data-article-id="#{id}"]), count: 1 }
    other_ids.each { |id| assert_select %(li[data-article-id="#{id}"]), count: 0 }
    assert_select 'script[src*="packs"]', count: 0
    assert_operator queries.length, :<=, 2, "content listing exceeded its query budget: #{queries.inspect}"
    assert queries.none? { |sql| sql.match?(/\b(?:COUNT|OFFSET)\b/i) }, "content listing used count/offset pagination: #{queries.inspect}"
  end

  test "uses bounded keyset pagination without a count query" do
    ids = insert_articles(users(:one), 27)
    log_in users(:one)

    post account_articles_path

    assert_response :success
    assert_select "li[data-article-id]", count: 25
    assert_select %(li[data-article-id="#{ids.max}"]), count: 1
    cursor = css_select('form[action="/account/articles"] input[name="before_id"]').first["value"]

    post account_articles_path, params: { before_id: cursor }

    assert_response :success
    assert_select "li[data-article-id]", count: 2
    assert_select 'form input[name="before_id"]', count: 0
  end

  test "rejects malformed pagination cursors before querying articles" do
    log_in users(:one)

    queries = count_database_queries do
      post account_articles_path, params: { before_id: "1 OR 1=1" }
    end

    assert_response :bad_request
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_operator queries.length, :<=, 1, "invalid cursor queried content: #{queries.inspect}"
  end

  test "opens owned metadata through POST without upload code" do
    article_id = insert_articles(users(:one), 1).first
    log_in users(:one)

    queries = count_database_queries { post edit_account_article_path(article_id) }

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select %(form[action="/account/articles/#{article_id}"])
    assert_select 'input[name="_method"][value="patch"]'
    assert_select 'input[type="file"]', count: 0
    assert_select 'script[src*="packs"]', count: 0
    assert_operator queries.length, :<=, 2, "metadata editor exceeded its query budget: #{queries.inspect}"
  end

  test "does not reveal another user's article editor" do
    article_id = insert_articles(users(:two), 1).first
    log_in users(:one)

    post edit_account_article_path(article_id)

    assert_response :not_found
    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "updates only owned article metadata" do
    article_id = insert_articles(users(:one), 1).first
    log_in users(:one)

    queries = count_database_queries do
      patch account_article_path(article_id), params: {
        article: {
          title: "Updated title", description: "Updated description",
          pages_count: 999, anonymous: true
        }
      }
    end

    assert_response :success
    assert_select '[role="status"]', text: "Article metadata updated."
    article = Article.find(article_id)
    assert_equal "Updated title", article.title
    assert_equal "Updated description", article.description
    assert_equal 1, article.pages_count
    assert_not article.anonymous?
    assert_operator queries.length, :<=, 7, "metadata update exceeded its query budget: #{queries.inspect}"
  end

  test "does not expose metadata editing through GET" do
    article_id = insert_articles(users(:one), 1).first

    get "/account/articles/#{article_id}/edit"

    assert_redirected_to "https://discord.gg/e97QGEA"
  end

  test "rejects metadata that exceeds the database title limit" do
    article_id = insert_articles(users(:one), 1).first
    log_in users(:one)

    patch account_article_path(article_id), params: {
      article: { title: "x" * 256, description: "Unchanged" }
    }

    assert_response :unprocessable_content
    assert_select '[role="alert"]', text: /Title is too long/
    assert_not_equal "x" * 256, Article.find(article_id).title
  end
end
