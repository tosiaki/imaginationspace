require "rails_helper"

RSpec.describe SubscriptionMailer, type: :mailer do
  describe "confirmation" do
    let(:mail) { SubscriptionMailer.confirmation }

    it "renders the headers" do
      expect(mail.subject).to eq("Confirmation")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("confirmation")
    end
  end

  describe "notification" do
    let(:comic) { create(:comic) }
    let(:user) { comic.user }
    let(:mail) { SubscriptionMailer.notification(work: comic, user: user) }

    it "renders the headers" do
      expect(mail.subject).to include("work")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("new")
    end
  end

end
