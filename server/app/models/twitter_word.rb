# == Schema Information
#
# Table name: twitter_words
#
#  id                :integer          not null, primary key
#  twitter_user_id   :string(255)      not null
#  twitter_user_name :string(255)
#  twitter_tweet_id  :string(255)      not null
#  tweet             :string(255)      not null
#  csv_url           :text(65535)
#  tweet_created_at  :datetime         not null
#  reply_to_tweet_id :string(255)
#
# Indexes
#
#  index_twitter_words_on_reply_to_tweet_id  (reply_to_tweet_id)
#  index_twitter_words_on_tweet_created_at   (tweet_created_at)
#  index_twitter_words_on_twitter_tweet_id   (twitter_tweet_id)
#  index_twitter_words_on_twitter_user_id    (twitter_user_id)
#

class TwitterWord < TwitterRecord
  belongs_to :parent, class_name: 'TwitterWord', foreign_key: :reply_to_tweet_id, primary_key: :twitter_tweet_id, optional: true
  has_many :children, class_name: 'TwitterWord', foreign_key: :reply_to_tweet_id, primary_key: :twitter_tweet_id
end
