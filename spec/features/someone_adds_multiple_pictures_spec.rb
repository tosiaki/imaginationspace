require "rails_helper"

RSpec.feature "Someone adds multiple pictures", :type => :feature do
  context 'as a guest' do
    describe 'when it is an existing article' do
    end
  end

  fcontext 'as a user' do
    describe 'when it is an existing article' do
      background do
        sign_in user
        visit article_path(article)
      end

      let!(:status) { create(:status) }
      let!(:article) { status.post }
      let(:user) { status.user }
      let(:article_page) { article.pages.first }

      it 'should add to separate pages when separate options are selected' do
        files = [File.join(Rails.root, 'spec', 'files', 'samplefile.jpg')]
        expect do
          click_link "Add page"
          attach_file "page_picture", files
          click_button "Post"
        end.to change{article.pages.count}.by(files.count-1)
      end
    end
  end
end