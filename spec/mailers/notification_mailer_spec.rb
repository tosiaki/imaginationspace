require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "follow" do
    let(:mail) { NotificationMailer.follow }

    it "renders the headers" do
      expect(mail.subject).to eq("Follow")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "kudos" do
    let(:mail) { NotificationMailer.kudos }

    it "renders the headers" do
      expect(mail.subject).to eq("Kudos")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "bookmark" do
    let(:mail) { NotificationMailer.bookmark }

    it "renders the headers" do
      expect(mail.subject).to eq("Bookmark")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "reply" do
    let(:mail) { NotificationMailer.reply }

    it "renders the headers" do
      expect(mail.subject).to eq("Reply")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "signal_boost" do
    let(:mail) { NotificationMailer.signal_boost }

    it "renders the headers" do
      expect(mail.subject).to eq("Signal boost")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
