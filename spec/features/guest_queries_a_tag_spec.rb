require "rails_helper"

RSpec.feature "Guest queries a tag", :type => :feature do
  context 'when there are works found' do
    describe 'the comics display' do
      let!(:comic) { create(:comic) }

      context 'with no nonzero stats' do
        background do
          visit works_search_path(tags: 'Tutorial')
        end

        it 'displays the title' do
          expect(page.body).to have_link(comic.title)
        end

        it 'displays the tags' do
          expect(page.body).to have_link(comic.fandom_list.first)
          expect(page.body).to have_link(comic.character_list.first)
          expect(page.body).to have_link(comic.relationship_list.first)
          expect(page.body).to have_link(comic.tag_list.first)
        end

        it 'displays the summary information' do
          expect(page.body).to include(comic.description)
        end

        it 'does not display data' do
          expect(page.body).to_not include('Comments')
          expect(page.body).to_not include('Kudos')
          expect(page.body).to_not include('Bookmarks')
          expect(page.body).to_not include('Hits')
        end
      end

      context "with nonzero stats" do
        given!(:second_user) { build(:second_user) }
        given(:user_id) { comic.user_id }

        background do
          comic.add_kudos(user: second_user)
          comment = comic.comments.build(attributes_for(:comment))
          comment.user_id = user_id
          comment.work = comic
          comment.save
          visit works_search_path(tags: 'Tutorial')
        end

        it 'does display stats' do
          expect(page.body).to include('Kudos')
          expect(page.body).to include('Comments')
          expect(page.body).to have_link(1, href: comic_path(comic, anchor: 'new_comment'))
        end
      end
    end
  end
end