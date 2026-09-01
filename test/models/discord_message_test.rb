require "test_helper"

class DiscordMessageTest < ActiveSupport::TestCase
  test "extracts unique referenced user IDs from messages" do
    messages = [
      DiscordMessage.new(content: "hello <@!123> and <@!456>"),
      DiscordMessage.new(content: "again <@!123> and <@789>"),
      DiscordMessage.new(content: nil)
    ]

    assert_equal [123, 456, 789], DiscordMessage.referenced_user_ids(messages)
  end
end
