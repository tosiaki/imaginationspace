require 'rails_helper'

RSpec.describe KudosController, type: :controller do

  it 'displays the home page' do
    visit '/'
    expect(page.body).to include("fancomics")
  end

end
