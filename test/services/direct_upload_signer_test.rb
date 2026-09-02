require "test_helper"

class DirectUploadSignerTest < ActiveSupport::TestCase
  FakeStorage = Struct.new(:requests) do
    def presign(key, **options)
      requests << [key, options]
      { url: "https://uploads.example.test/#{key}?signed=true" }
    end
  end

  test "signs a bounded single-part upload with a short lifetime" do
    storage = FakeStorage.new([])
    key = "c56a4180-65aa-42ec-a945-5fd21dec0538.png"

    result = DirectUploadSigner.new(storage: storage).call(method: "PUT", key: key, size: 123)

    assert_equal "https://uploads.example.test/#{key}?signed=true", result.fetch(:url)
    assert_equal [
      [key, { method: :put, expires_in: 15.minutes.to_i, content_length: 123 }]
    ], storage.requests
  end

  test "rejects unsupported operations, unsafe keys, and invalid sizes" do
    signer = DirectUploadSigner.new(storage: FakeStorage.new([]))
    key = "c56a4180-65aa-42ec-a945-5fd21dec0538.png"

    assert_raises(DirectUploadSigner::InvalidRequest) { signer.call(method: "DELETE", key: key, size: 1) }
    assert_raises(DirectUploadSigner::InvalidRequest) { signer.call(method: "PUT", key: "../stored-file", size: 1) }
    assert_raises(DirectUploadSigner::InvalidRequest) { signer.call(method: "PUT", key: key, size: 0) }
    assert_raises(DirectUploadSigner::InvalidRequest) do
      signer.call(method: "PUT", key: key, size: DirectUploadSigner::MAXIMUM_FILE_SIZE + 1)
    end
  end
end
