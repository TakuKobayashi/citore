# == Schema Information
#
# Table name: twitter_bots
#
#  id                   :integer          not null, primary key
#  type                 :string(255)      not null
#  action               :integer          not null
#  action_value         :string(255)      not null
#  action_resource_path :string(255)
#  action_id            :string(255)      not null
#  action_time          :datetime         not null
#  action_from_id       :integer
#
# Indexes
#
#  index_twitter_bots_on_action_from_id   (action_from_id)
#  index_twitter_bots_on_action_id        (action_id)
#  index_twitter_bots_on_type_and_action  (type,action)
#

class Mone::TwitterBot < TwitterBot
  def self.get_twitter_rest_client
    return TwitterRecord.get_twitter_rest_client("citore")
  end

  def self.get_twitter_stream_client
    return TwitterBot.get_twitter_stream_client("129772274")
  end

  def self.get_tweet
    prefix_rand_id = rand(MarkovTrigramPrefix.where(source_type: "CharacterSerif").first.id..MarkovTrigramPrefix.where(source_type: "CharacterSerif").last.id)
    prefix = MarkovTrigramPrefix.where(source_type: "CharacterSerif").where("id > ?", prefix_rand_id).first
    return MarkovTrigramPrefix.generate_sentence(seed: prefix.prefix, source_type: "CharacterSerif")
  end
end
