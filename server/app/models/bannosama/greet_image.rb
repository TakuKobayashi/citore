# == Schema Information
#
# Table name: bannosama_greet_images
#
#  id               :integer          not null, primary key
#  greet_id         :integer          not null
#  origin_file_name :string(255)      not null
#  upload_url       :string(255)      not null
#  score            :float(24)        default(0.0), not null
#  width            :integer          default(0), not null
#  height           :integer          default(0), not null
#  options          :text(65535)
#
# Indexes
#
#  index_bannosama_greet_images_on_greet_id  (greet_id)
#  index_bannosama_greet_images_on_score     (score)
#

class Bannosama::GreetImage < ApplicationRecord
  serialize :options, JSON
  belongs_to :greet, class_name: 'Bannosama::Greet', foreign_key: :greet_id, required: false
end
