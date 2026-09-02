require "test_helper"

class DirectUploadsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  tests DirectUploadsController

  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      devise_for :users
      post "s3/params", to: "direct_uploads#create"
    end
    @original_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @parameters = {
      method: "PUT",
      key: "c56a4180-65aa-42ec-a945-5fd21dec0538.png",
      size: 123
    }
  end

  teardown do
    ActionController::Base.allow_forgery_protection = @original_forgery_protection
  end

  test "rejects an unauthenticated signing request" do
    @request.headers["X-CSRF-Token"] = @controller.send(:form_authenticity_token)
    post :create, params: @parameters, format: :json

    assert_response :unauthorized
  end

  test "rejects an authenticated request without a CSRF token" do
    sign_in users(:one)

    assert_raises(ActionController::InvalidAuthenticityToken) do
      post :create, params: @parameters, format: :json
    end
  end

  test "returns a signed URL for an authenticated request with a CSRF token" do
    sign_in users(:one)
    @request.headers["X-CSRF-Token"] = @controller.send(:form_authenticity_token)
    calls = []
    signer = Object.new
    signer.define_singleton_method(:call) do |**parameters|
      calls << parameters
      { url: "https://uploads.example.test/signed" }
    end
    @controller.define_singleton_method(:upload_signer) { signer }

    post :create, params: @parameters, format: :json

    assert_response :success
    assert_equal({ "url" => "https://uploads.example.test/signed" }, response.parsed_body)
    assert_equal 1, calls.size
    assert_equal "PUT", calls.fetch(0).fetch(:method)
    assert_equal @parameters.fetch(:key), calls.fetch(0).fetch(:key)
    assert_equal 123, calls.fetch(0).fetch(:size)
  end

  test "returns an unprocessable response for an unsafe signing request" do
    sign_in users(:one)
    @request.headers["X-CSRF-Token"] = @controller.send(:form_authenticity_token)
    signer = Object.new
    signer.define_singleton_method(:call) do |**|
      raise DirectUploadSigner::InvalidRequest, "Invalid upload key"
    end
    @controller.define_singleton_method(:upload_signer) { signer }

    post :create, params: @parameters.merge(key: "../stored-file"), format: :json

    assert_response :unprocessable_entity
    assert_equal({ "error" => "Invalid upload key" }, response.parsed_body)
  end

  test "rejects a malformed file size" do
    sign_in users(:one)
    @request.headers["X-CSRF-Token"] = @controller.send(:form_authenticity_token)

    post :create, params: @parameters.merge(size: "123abc"), format: :json

    assert_response :unprocessable_entity
    assert_equal({ "error" => "Invalid file size" }, response.parsed_body)
  end
end
