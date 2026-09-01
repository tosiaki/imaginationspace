require "test_helper"

class LeaderboardHelperTest < ActionView::TestCase
  tests LeaderboardHelper

  test "accepts only absolute HTTP URLs" do
    assert_equal "https://example.com/image.png", external_http_url("https://example.com/image.png")
    assert_equal "http://example.com/image.png", external_http_url("http://example.com/image.png")
    assert_nil external_http_url("javascript:alert(1)")
    assert_nil external_http_url("/relative/path")
    assert_nil external_http_url("not a URL")
  end

  test "matches an exact external host" do
    assert external_host?("https://www.youtube.com/embed/example", "www.youtube.com")
    refute external_host?("https://www.youtube.com.example.org/embed/example", "www.youtube.com")
    refute external_host?("invalid", "www.youtube.com")
  end

  test "escapes stored message HTML" do
    rendered = insert_references('<script>alert("x")</script>')

    assert_includes rendered, "&lt;script&gt;"
    refute_includes rendered, "<script>"
  end

  test "renders Discord emoji as deferred images" do
    rendered = insert_references("hello <:wave:12345>")

    assert_includes rendered, "https://cdn.discordapp.com/emojis/12345.png"
    assert_includes rendered, 'loading="lazy"'
    assert_includes rendered, 'decoding="async"'
  end
end
