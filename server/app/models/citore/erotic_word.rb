# == Schema Information
#
# Table name: citore_erotic_words
#
#  id              :integer          not null, primary key
#  twitter_word_id :integer
#  origin          :string(255)      not null
#  reading         :string(255)      not null
#  appear_count    :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_citore_erotic_words_on_twitter_word_id  (twitter_word_id)
#

class Citore::EroticWord < TwitterRecord
  has_many :ngrams, as: :from, class_name: 'NgramWord'
  has_many :voices, as: :from, class_name: 'VoiceWord'

  ERO_KOTOBA_BOT = "ero_kotoba_bot"

  def self.import_tweet!(tweet_results:, generate_voice: false)
    tweet_results.each do |status|
      next if status.blank?
      next if TwitterWord.exists?(twitter_tweet_id: status.id)
      sanitaized_word = TwitterRecord.sanitized(status.text)
      without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)
      tweet = ApplicationRecord.delete_symbols(without_url_tweet)
      TwitterWord.transaction do
        tweet = TwitterWord.create!(
          twitter_user_id: status.user.id.to_s,
          twitter_user_name: status.user.screen_name.to_s,
          twitter_tweet_id: status.id.to_s,
          tweet: tweet,
          csv_url: urls.join(","),
          tweet_created_at: status.created_at
        )
        Citore::EroticWord.generate_data_and_voice!(text: sanitaized_word, twitter_word_id: tweet.id, generate_voice: generate_voice)
      end
    end
  end

  def self.reading_words
    records = CacheStore::CACHE.read(self.table_name)
    if records.blank?
      return sCitore::EroticWord.pluck(:reading)
    end
    return records.values.map(&:reading)
  end

  def self.generate!(text, twitter_word_id = nil)
    reading = ApplicationRecord.reading(text)
    erotic_word = Citore::EroticWord.find_or_initialize_by(reading: reading)
    new_record = erotic_word.new_record?
    if new_record
      erotic_word.twitter_word_id = twitter_word_id
    end
    erotic_word.origin = text
    erotic_word.appear_count = erotic_word.appear_count.to_i + 1
    erotic_word.save!
    if new_record
      words = ApplicationRecord.ngram(reading, 2).uniq
      #なぜか謎のloadが入ってしまうのでimportするのは一回だけ
      values = words.map{|word| "(" + ["NULL", "'#{erotic_word.class.base_class.name}'", erotic_word.id, "'#{word}'"].join(",") + ")" }
      sql = "INSERT INTO `#{NgramWord.table_name}` (#{NgramWord.column_names.join(',')}) VALUES " + values.join(",")
      NgramWord.connection.execute(sql)
    end
    return erotic_word
  end
end
