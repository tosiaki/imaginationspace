require 'rails_helper'

RSpec.describe Kudo, type: :model do
  context 'when the comic exists' do
    let!(:comic) { create(:comic) }
    let!(:user) { comic.user }

    def user_giving_kudos
      comic.add_kudos(user: user)
    end

    def ip_giving_kudos
      comic.add_kudos(ip_address: '192.168.0.1')
    end

    it 'can be given' do
      expect {user_giving_kudos}.to change {comic.kudos.count}.from(0).to(1)
      expect {user_giving_kudos}.to_not change {comic.kudos.count}
      expect {ip_giving_kudos}.to change {comic.kudos.count}.from(1).to(2)
      expect {ip_giving_kudos}.to_not change {comic.kudos.count}
    end
  end
end
