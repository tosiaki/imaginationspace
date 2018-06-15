require "rails_helper"

RSpec.describe "home page" do
  it 'displays the site name' do
    visit '/'
    expect(page.body).to include("Fancomics")
  end

  pending 'greets the user when logged in'
end