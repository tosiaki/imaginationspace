require "application_system_test_case"

class DeferredVideoEmbedTest < ApplicationSystemTestCase
  test "creates an external iframe only after explicit activation" do
    source = "https://example.invalid/embed/video"
    markup = <<~HTML
      <!doctype html>
      <html>
        <body>
          <div class="deferred-video-embed">
            <button type="button" class="deferred-video-load"
              data-embed-src="#{source}" data-embed-title="Example video">
              Load Example video
            </button>
          </div>
        </body>
      </html>
    HTML

    visit "data:text/html;charset=utf-8,#{ERB::Util.url_encode(markup)}"
    page.execute_script Rails.root.join("app/assets/javascripts/external_embeds.js").read

    assert_no_selector "iframe"
    click_button "Load Example video"

    frame = find("iframe")
    assert_equal source, frame[:src]
    assert_equal "Example video", frame[:title]
    assert_equal "strict-origin-when-cross-origin", frame[:referrerpolicy]
    assert_equal "encrypted-media; picture-in-picture", frame[:allow]
  end
end
