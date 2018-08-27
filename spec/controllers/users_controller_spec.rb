require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  it 'displays the signup form' do
    visit '/signup'
    expect(page.body).to include("email")
    expect(page.body).to include("password")
  end

  it 'displays the home page' do
  	visit '/'
  	expect(page.body).to include("fancomics")
  end
end
