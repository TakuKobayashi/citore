class FeyKunJob < ApplicationJob
  queue_as :default

  def perform(image)
    image.request_analize!
  end
end
