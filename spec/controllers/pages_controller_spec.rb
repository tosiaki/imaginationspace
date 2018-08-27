require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  it 'displays the site name' do
    visit '/'
    expect(page.body).to include("Fancomics")
  end

  it 'contains Home | Fancomics in the title' do
    visit '/'
    expect(page.title).to eq("Home | Fancomics")
  end
  
  it 'displays the about page' do
    visit '/about'
    expect(page.body).to include("about")
  end

  pending 'greets the user when logged in'
end
