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
  def self.routine_tweet!
    bot = Mone::TwitterBot.new(action: :tweet)
    bot.tweet!(get_tweet)
  end

  def tweet!(text)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))

    extra_info = ExtraInfo.read_extra_info
    mone_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = apiconfig["twitter"]["consumer_key"]
      config.consumer_secret     = apiconfig["twitter"]["consumer_secret"]
      config.access_token        = extra_info["twitter_129772274"]["token"]
      config.access_token_secret = extra_info["twitter_129772274"]["token_secret"]
    end
    tweeted = mone_client.update(text)
    update!(action_id: tweeted.id,action_value: text, action_time: tweeted.created_at)
  end

  def self.get_tweet
    prefix_rand_id = rand(MarkovTrigramPrefix.where(source_type: "CharacterSerif").first.id..MarkovTrigramPrefix.where(source_type: "CharacterSerif").last.id)
    prefix = MarkovTrigramPrefix.where(source_type: "CharacterSerif").where("id > ?", prefix_rand_id).first
    return MarkovTrigramPrefix.generate_sentence(seed: prefix.prefix, source_type: "CharacterSerif")
  end
end
