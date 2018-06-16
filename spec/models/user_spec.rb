require 'rails_helper'

RSpec.describe User, type: :model do
  before {
  	@user = User.new(email: "valid@example.com", name: "Username", password: "password", password_confirmation: "password", confirmed_at: Time.now)
  }

  it "should accept valid user info" do
  	expect(@user.valid?).to be_truthy
  end

  it "should not validate empty usernames" do
    @user.name="";
    expect(@user.valid?).to be_falsey
  end

  it "should not validate empty emails" do
    @user.email="";
    expect(@user.valid?).to be_falsey
  end

  it "should guarantee uniqueness of emails" do
    duplicate_user = @user.dup
    @user.save(validate: false)
    expect(duplicate_user.valid?).to be_falsey
  end

  # it "should not distinguish emails by case" do
  #   mixed_case_email = "vaLID@eXamPle.CoM"
  #   @user.email = mixed_case_email
  #   @user.save(validate: false)
  #   duplicate_user = @user.dup
  #   duplicate_user.email = mixed_case_email.downcase
  #   expect(duplicate_user.valid?).to be_falsey
  # end
end
