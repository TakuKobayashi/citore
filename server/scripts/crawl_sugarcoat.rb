#last_id = TweetSeed.where(search_keyword: serach_keyword).last.try(:tweet_id_str)

CrawlScheduler.tweet_crawl("search", "オブラート -rt", {:lang => "ja"}) do |tweet_statuses|
  tweet_seeds = []
  tweet_statuses.each do |status|
    next if status.blank?
    sanitaized_word = TweetVoiceSeedDynamo.sanitized(status.text)
    split_words = TweetVoiceSeedDynamo.bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end
    split_words.each do |word|
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
        tree_separate_words << cells[0]
      end
    end
  end
  #last_id = tweet_statuses.select{|s| s.try(:id).present? }.min_by{|s| s.id.to_i }.try(:id).to_i
end