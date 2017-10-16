# == Schema Information
#
# Table name: datapool_websites
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  title      :string(255)      not null
#  origin_src :string(255)      not null
#  query      :text(65535)
#  options    :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_origin_src  (origin_src)
#  index_datapool_websites_on_title       (title)
#

class Datapool::TwitterWebsite < Datapool::Website
  def self.constract_from_tweet(tweet:, options: {})
    return [] unless tweet.urls?
    tweet_text = ApplicationRecord.basic_sanitize(tweet.text)
    tweet_text = ApplicationRecord.separate_urls(tweet_text).first

    websites = tweet.urls.flat_map do |urle|
      self.constract(url: urle.expanded_url.to_s, title: tweet_text, options: {tweet_id: tweet.id, tweet_text: tweet_text}.merge(options))
    end
    return websites
  end
end
