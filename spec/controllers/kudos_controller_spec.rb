require 'rails_helper'

RSpec.describe KudosController, type: :controller do
  let!(:comic) { create(:comic) }

  def post_kudos
    post :create, params: { parent: "Comic", comic_id: comic.id }
  end
  
  context 'as a guest' do
    it 'increases the kudos the first time' do
      expect {post_kudos}.to change {comic.kudos.count}.from(0).to(1)
      expect {post_kudos}.to_not change {comic.kudos.count}
    end
  end

  context 'as another user' do
    let(:other_user) { create(:second_user) }

    before { sign_in other_user }

    it 'increases the kudos the first time' do
      expect {post_kudos}.to change {comic.kudos.count}.from(0).to(1)
      expect {post_kudos}.to_not change {comic.kudos.count}
    end
  end

  context 'as the submitter' do
    before { sign_in comic.user }

    it 'does not increase kudos' do
      expect {post_kudos}.to_not change {comic.kudos.count}
    end
  end
end