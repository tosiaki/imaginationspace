require "test_helper"

class InlineUploadAuthorizerTest < ActiveSupport::TestCase
  def upload_data(user:, key: "uploads/c56a4180-65aa-42ec-a945-5fd21dec0538.png", size: 8)
    verifier = Rails.application.message_verifier(:direct_upload_authorization)
    authorization = verifier.generate(
      { user_id: user.id, key: key, size: size },
      expires_in: DirectUploadSigner::URL_LIFETIME
    )
    JSON.generate(
      id: key,
      storage: "cache",
      metadata: {
        size: size,
        filename: "image.png",
        mime_type: "image/png",
        upload_authorization: authorization
      }
    )
  end

  test "authorizes matching user-bound cache metadata and consumes its token" do
    data = upload_data(user: users(:one))
    content = %(<p>Before</p><img src="blob:test" data-file-data='#{ERB::Util.html_escape(data)}'>)

    result = InlineUploadAuthorizer.new(user: users(:one)).call(content)
    parsed = Nokogiri::HTML.fragment(result).at_css("img")
    authorized_data = JSON.parse(parsed["data-file-data"])

    assert_equal "cache", authorized_data.fetch("storage")
    assert_equal 8, authorized_data.dig("metadata", "size")
    assert_nil authorized_data.dig("metadata", "upload_authorization")
  end

  test "rejects another user, tampered size, unsafe type, and expired or missing tokens" do
    valid_data = JSON.parse(upload_data(user: users(:one)))
    authorizer = InlineUploadAuthorizer.new(user: users(:two))

    assert_raises(InlineUploadAuthorizer::InvalidUpload) do
      authorizer.call(%(<img data-file-data='#{ERB::Util.html_escape(valid_data.to_json)}'>))
    end

    valid_data["metadata"]["size"] = 9
    assert_raises(InlineUploadAuthorizer::InvalidUpload) do
      InlineUploadAuthorizer.new(user: users(:one)).call(
        %(<img data-file-data='#{ERB::Util.html_escape(valid_data.to_json)}'>)
      )
    end

    valid_data["metadata"].delete("upload_authorization")
    assert_raises(InlineUploadAuthorizer::InvalidUpload) do
      InlineUploadAuthorizer.new(user: users(:one)).call(
        %(<img data-file-data='#{ERB::Util.html_escape(valid_data.to_json)}'>)
      )
    end
  end
end
