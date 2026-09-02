require "test_helper"
require "base64"
require "stringio"

class AccountArticlePagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Users::SessionsController::LOGIN_RATE_LIMIT_STORE.clear
  end

  def log_in(user)
    post login_path, params: {
      user: { email: user.email, password: "password" }
    }
    follow_redirect!
  end

  def insert_article_with_pages(user, page_count: 1)
    now = Time.current
    article_id = Article.insert_all!([{
      title: "Owned article", pages_count: page_count,
      max_pages: page_count, planned_pages: page_count,
      created_at: now, updated_at: now
    }], returning: %w[id]).rows.dig(0, 0)
    Article.where(id: article_id).update_all(thread_id: article_id)
    Page.insert_all!((1..page_count).map do |page_number|
      {
        article_id: article_id, page_number: page_number,
        title: "Page #{page_number}", content: "Content #{page_number}",
        created_at: now, updated_at: now
      }
    end)
    Status.insert_all!([{
      user_id: user.id, post_type: "Article", post_id: article_id,
      timeline_time: now, created_at: now, updated_at: now
    }])
    article_id
  end

  test "requires authentication without loading an article" do
    queries = count_database_queries { post account_article_pages_path(1) }

    assert_redirected_to login_path
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_empty queries
  end

  test "lists an owned article's pages with bounded keyset pagination" do
    article_id = insert_article_with_pages(users(:one), page_count: 51)
    log_in users(:one)

    queries = count_database_queries { post account_article_pages_path(article_id) }

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select "li[data-page-number]", count: 50
    assert_select 'form input[name="after_page"][value="50"]', count: 1
    assert queries.none? { |sql| sql.match?(/\b(?:COUNT|OFFSET)\b/i) }, "page listing used count/offset pagination: #{queries.inspect}"
    assert_operator queries.length, :<=, 3, "page listing exceeded its query budget: #{queries.inspect}"

    post account_article_pages_path(article_id), params: { after_page: "50" }

    assert_response :success
    assert_select "li[data-page-number]", count: 1
    assert_select 'form input[name="after_page"]', count: 0
  end

  test "opens an owned page editor with only the private upload pack" do
    article_id = insert_article_with_pages(users(:one))
    log_in users(:one)

    queries = count_database_queries { post edit_account_article_page_path(article_id, 1) }

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select %(form[action="/account/articles/#{article_id}/pages/1"])
    assert_select 'input[name="_method"][value="patch"]'
    assert_select 'input[type="file"][data-private-page-upload]', count: 1
    assert_select 'script[src*="private_page_editor"]', minimum: 1
    assert_select 'script[src*="svelte_parts"]', count: 0
    assert_operator queries.length, :<=, 3, "page editor exceeded its query budget: #{queries.inspect}"
  end

  test "updates owned page content while preserving ordinary images" do
    article_id = insert_article_with_pages(users(:one))
    log_in users(:one)
    content = '<p>Updated</p><img src="https://images.example.test/example.png">'

    queries = count_database_queries do
      patch account_article_page_path(article_id, 1), params: {
        page: { title: "Updated page", content: content, page_number: 99 }
      }
    end

    assert_response :success
    assert_select '[role="status"]', text: "Page updated."
    page = Page.find_by!(article_id: article_id, page_number: 1)
    assert_equal "Updated page", page.title
    assert_equal content, page.content
    assert_equal "https://images.example.test/example.png", page.display_image
    assert_operator queries.length, :<=, 7, "page update exceeded its query budget: #{queries.inspect}"
  end

  test "rejects inline upload data without valid user-bound authorization" do
    article_id = insert_article_with_pages(users(:one))
    log_in users(:one)
    original_content = Page.find_by!(article_id: article_id, page_number: 1).content
    picture_count = ShrinePicture.count

    patch account_article_page_path(article_id, 1), params: {
      page: { content: '<img src="blob:test" data-file-data="{&quot;storage&quot;:&quot;cache&quot;}">' }
    }

    assert_response :unprocessable_content
    assert_select '[role="alert"]', text: /Content Invalid or expired upload authorization/
    assert_equal original_content, Page.find_by!(article_id: article_id, page_number: 1).content
    assert_equal picture_count, ShrinePicture.count
  end

  test "consumes valid upload authorization and creates a Shrine attachment" do
    article_id = insert_article_with_pages(users(:one))
    log_in users(:one)
    key = "c56a4180-65aa-42ec-a945-5fd21dec0538.png"
    image_bytes = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=")
    size = image_bytes.bytesize
    authorization = Rails.application.message_verifier(:direct_upload_authorization).generate(
      { user_id: users(:one).id, key: key, size: size },
      expires_in: DirectUploadSigner::URL_LIFETIME
    )
    Shrine.storages[:cache].upload(
      StringIO.new(image_bytes), key,
      shrine_metadata: { "filename" => "image.png", "size" => size, "mime_type" => "image/png" }
    )
    upload_data = {
      id: key, storage: "cache",
      metadata: {
        size: size, filename: "image.png", mime_type: "image/png",
        upload_authorization: authorization
      }
    }

    assert_difference("ShrinePicture.count", 1) do
      patch account_article_page_path(article_id, 1), params: {
        page: {
          content: %(<p>Before</p><img src="blob:test" data-file-data='#{ERB::Util.html_escape(upload_data.to_json)}'>)
        }
      }
      assert_response :success
    end

    page_record = Page.find_by!(article_id: article_id, page_number: 1)
    assert_not_includes page_record.content, "data-file-data"
    assert_not_includes ShrinePicture.order(:id).last.picture_data, "upload_authorization"
  ensure
    Shrine.storages[:cache].delete(key) if key && Shrine.storages[:cache].exists?(key)
  end

  test "does not reveal another user's article or page" do
    article_id = insert_article_with_pages(users(:two))
    log_in users(:one)

    post edit_account_article_page_path(article_id, 1)

    assert_response :not_found
    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "does not expose page management through GET" do
    article_id = insert_article_with_pages(users(:one))

    get "/account/articles/#{article_id}/pages"
    assert_redirected_to "https://discord.gg/e97QGEA"

    get "/account/articles/#{article_id}/pages/1/edit"
    assert_redirected_to "https://discord.gg/e97QGEA"
  end
end
