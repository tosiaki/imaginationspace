class PromoteJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Shrine::Attacher.promote(data)
  end
end
