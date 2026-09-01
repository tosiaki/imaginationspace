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

  test "renders user mentions from the preloaded name map" do
    @discord_user_names = { 12345 => "Example User" }

    assert_equal "hello @Example User", insert_references("hello <@!12345>")
  end

  test "renders an unknown user mention without querying" do
    @discord_user_names = {}

    assert_equal "hello @12345", insert_references("hello <@!12345>")
  end

  test "renders Discord mentions without the legacy exclamation mark" do
    @discord_user_names = { 12345 => "Example User" }

    assert_equal "hello @Example User", insert_references("hello <@12345>")
  end

  test "defers third-party video frames until an explicit action" do
    rendered = deferred_video_embed("https://www.youtube.com/embed/example", title: "YouTube video")

    assert_includes rendered, 'data-embed-src="https://www.youtube.com/embed/example"'
    assert_includes rendered, "Load YouTube video"
    assert_includes rendered, 'rel="nofollow ugc noopener noreferrer"'
    refute_includes rendered, "<iframe"
  end

  test "does not render a deferred embed for unsafe URLs" do
    assert_nil deferred_video_embed("javascript:alert(1)", title: "Unsafe video")
  end
end
