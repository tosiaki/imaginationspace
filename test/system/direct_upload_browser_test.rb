require "application_system_test_case"
require "json"
require "tempfile"

class DirectUploadBrowserTest < ApplicationSystemTestCase
  test "uploads through Uppy 6 and creates Shrine attachment data" do
    markup = <<~HTML
      <!doctype html>
      <html>
        <head><meta name="csrf-token" content="browser-test-csrf"></head>
        <body>
          <div class="file-input-area">
            <div class="preview-area"></div>
            <input id="article_picture" class="new-post-pictures"
              name="article[picture]" type="file" accept="image/png">
            <label class="file-upload-label" for="article_picture">Add picture</label>
          </div>
        </body>
      </html>
    HTML

    visit "data:text/html;charset=utf-8,#{ERB::Util.url_encode(markup)}"
    install_network_fakes
    load_uppy_pack
    handler = Rails.root.join("app/assets/javascripts/uppy_handler.js").read
    page.execute_script "#{handler}\nwindow.useUppy = useUppy;"
    page.execute_script "window.useUppy(document)"

    image = Tempfile.new(["direct-upload", ".png"])
    image.binmode
    image.write("\x89PNG\r\n\x1a\n")
    image.close

    attach_file "article_picture", image.path, make_visible: true
    assert_selector "[role=status]", text: "Upload complete", wait: 10

    signing_request = page.evaluate_script("window.testSigningRequest")
    assert_equal "/s3/params", signing_request.fetch("url")
    assert_equal "POST", signing_request.fetch("options").fetch("method")
    assert_equal "browser-test-csrf",
      signing_request.fetch("options").fetch("headers").fetch("X-CSRF-Token")

    authorization = JSON.parse(signing_request.fetch("options").fetch("body"))
    assert_equal "PUT", authorization.fetch("method")
    assert_equal 8, authorization.fetch("size")
    assert_match(/\A[0-9a-f-]{36}\.png\z/, authorization.fetch("key"))

    storage_request = page.evaluate_script("window.testStorageRequest")
    assert_equal "PUT", storage_request.fetch("method")
    assert_equal 8, storage_request.fetch("size")
    assert_equal "image/png", storage_request.fetch("headers").fetch("Content-Type")

    attachment = JSON.parse(find("input[type=hidden]", visible: :all).value)
    assert_equal authorization.fetch("key"), attachment.fetch("id")
    assert_equal "cache", attachment.fetch("storage")
    assert_equal 8, attachment.dig("metadata", "size")
    assert_match(/\Adirect-upload.*\.png\z/, attachment.dig("metadata", "filename"))
    assert_equal "image/png", attachment.dig("metadata", "mime_type")
  ensure
    image&.close!
  end

  private

  def load_uppy_pack
    Shakapacker.compile
    manifest = JSON.parse(Rails.root.join("public/packs-test/manifest.json").read)
    manifest.dig("entrypoints", "uppy", "assets", "js").each do |asset|
      relative_asset = asset.delete_prefix("/packs-test/")
      page.execute_script Rails.root.join("public/packs-test", relative_asset).read
    end
  end

  def install_network_fakes
    page.execute_script <<~JAVASCRIPT
      window.testSigningRequest = null;
      window.testStorageRequest = null;
      window.$ = function() { return { on: function() {} }; };
      Object.defineProperty(window.crypto, 'randomUUID', {
        value: function() { return 'c56a4180-65aa-42ec-a945-5fd21dec0538'; }
      });

      window.fetch = async function(url, options) {
        window.testSigningRequest = { url: url, options: options };
        var request = JSON.parse(options.body);
        return {
          ok: true,
          status: 200,
          json: async function() {
            return { url: 'https://uploads.example.test/' + request.key + '?signed=true' };
          }
        };
      };

      class TestXMLHttpRequest {
        constructor() {
          this.upload = {};
          this.status = 200;
          this.statusText = 'OK';
          this.responseText = '';
          this.requestHeaders = {};
        }

        open(method, url) {
          this.method = method;
          this.url = url;
        }

        setRequestHeader(name, value) {
          this.requestHeaders[name] = value;
        }

        getResponseHeader(name) {
          return name.toLowerCase() === 'etag' ? '"browser-test-etag"' : null;
        }

        send(body) {
          window.testStorageRequest = {
            method: this.method,
            url: this.url,
            headers: this.requestHeaders,
            size: body.size
          };
          if (this.upload.onprogress) {
            this.upload.onprogress({ lengthComputable: true, loaded: body.size, total: body.size });
          }
          setTimeout(() => this.onload(), 0);
        }

        abort() {}
      }

      window.XMLHttpRequest = TestXMLHttpRequest;
    JAVASCRIPT
  end
end
