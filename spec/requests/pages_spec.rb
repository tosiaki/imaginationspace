require "rails_helper"

RSpec.describe "home page" do
  it 'display the home page' do
    get '/'
    assert_match 'Fancomics', response.body
  end
end