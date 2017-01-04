# == Schema Information
#
# Table name: sugarcoat_seeds
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Sugarcoat::Seed < TwitterRecord
  def self.to_sugarcoat(text, options = {})
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    sanitaized_word = ApplicationRecord.basic_sanitize(text)
    sanitaized_word, urls = separate_urls(sanitaized_word)
    split_words = bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end
    extra = CrawlScheduler.read_extra_info

    words = split_words.map do |word|
      tree_separate_words = []
      parser = CaboCha::Parser.new
      tree = parser.parse(word)
      output = tree.toString(CaboCha::FORMAT_LATTICE)
      output_lines = output.split("\n")
      output_lines.each do |line|
        cells = line.split(" ")
        if cells[0].blank? || cells[0] == "*"
          tree_separate_words = []
          next
        end
        next if cells[1].blank?
        features = cells[1].split(",")
        score = get_word_score(features[0].force_encoding("utf-8"), cells[0].force_encoding("utf-8"))
        if score.blank?
          tree_separate_words << cells[0]
          next
        end
        if score >= extra["ja_average_score"].to_f
          tree_separate_words << cells[0]
          next
        end
        list = `http -a #{apiconfig["metadata_wordassociator"]["username"]}:#{apiconfig["metadata_wordassociator"]["password"]} GET wordassociator.ap.mextractr.net/word_associator/api_query query==#{cells[0]}`
        max_word = JSON.parse(list).max_by{|arr| get_word_score(arr[0].strip, features[0].strip) }
        tree_separate_words << max_word[0]
      end
      tree_separate_words.join("")
    end
    return words
  end

  def self.get_word_score(cverb, word)
    verbs = EmotionalWordDynamo::PARTS.keys
    verb = verbs.detect{|v| cverb.include?(v) }
    return nil if verb.blank?
    v = EmotionalWordDynamo::PARTS[verb]
    reading_word = ApplicationRecord.reading(word)
    emotion = EmotionalWordDynamo.find(word: word, reading: reading_word, part: v)
    return nil if emotion.blank?
    return emotion.score.to_f
  end
end
