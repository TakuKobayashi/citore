require 'google/apis/youtube_v3'

namespace :batch do

  task export_to_csv_from_dynamodb: :environment do
    Aws.config.update(Rails.application.config_for(:aws).symbolize_keys)
    table_name = ARGV.last
    client = Aws::DynamoDB::Client.new
    start_key = nil
    counter = 0
    CSV.open(Rails.root.to_s + "/tmp/" + table_name + ".csv", "wb") do |csv|
      results = []
      begin
        counter += 1
        results = client.scan(table_name: table_name, limit: 500, exclusive_start_key: start_key)
        results.items.each_with_index do |hash, index|
          if index == 0 && start_key.blank?
            csv << hash.keys
          end
          values = hash.values
          csv << values.map do |v|
            if v.instance_of?(Array) || v.instance_of?(Hash)
              v.to_json
            else
              v.to_s
            end
          end
        end
        puts "#{counter}:#{results.count}:#{results.last_evaluated_key}"
        start_key = results.last_evaluated_key
      end while start_key.present?
    end
    # 空タスク作ってエラーを握りつぶす
    ARGV.slice(1,ARGV.size).each{|v| task v.to_sym do; end}
  end

  task import_to_dynamodb_from_table: :environment do
    Aws.config.update(Rails.application.config_for(:aws).symbolize_keys)
    client = Aws::DynamoDB::Client.new
    {
      TwitterWord => "TwitterWordDynamo",
      AppearWord => "AppearWordDynamo",
      MarkovTrigram => "MarkovTrigramDynamo",
    }.each do |activerecord_clazz, dynamodb_tablename|
      activerecord_clazz.find_in_batches do |clazzes|
        clazzes.each_slice(25) do |records|
          client.batch_write_item({
            request_items: {
              dynamodb_tablename => records.map{|r| {put_request: {item: r.attributes} } }
            }
          })
        end
      end
    end
  end

  task rebuild_twitter_replay_id: :environment do
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = apiconfig["twitter"]["consumer_key"]
      config.consumer_secret     = apiconfig["twitter"]["consumer_secret"]
      config.access_token        = apiconfig["twitter"]["access_token_key"]
      config.access_token_secret = apiconfig["twitter"]["access_token_secret"]
    end
    limit_span = (15.minutes.second / 300).to_i
    TwitterWord.find_in_batches do |words|
      words.each_slice(100) do |w|
        begin
          t_words = []
          tweets = client.statuses(w.map(&:twitter_tweet_id))
          tweets.each do |status|
            tw_word = w.detect{|wt| wt.twitter_tweet_id.to_s == status.id.to_s }
            if tw_word.present?
              tw_word.reply_to_tweet_id = status.in_reply_to_status_id.to_s
              t_words << tw_word
            end
          end
          TwitterWord.import(t_words, on_duplicate_key_update: [:reply_to_tweet_id])
          sleep limit_span
        rescue
          sleep 60
          retry
        end
      end
    end
  end

  task import_sql_from_wikipedia: :environment do
    [
        [WikipediaTopicCategory, "jawiki-latest-category.sql.gz"],
        [WikipediaPage, "jawiki-latest-page.sql.gz"]
#        [WikipediaCategoryPage, "jawiki-latest-categorylinks.sql.gz"]
    ].each do |clazz, file_name|
      puts "#{clazz.table_name} download start"
      gz_file_path = clazz.download_file(file_name)
      puts "#{clazz.table_name} decompress start"
      query_string = clazz.decompress_gz_query_string(gz_file_path)
      puts "#{clazz.table_name} save file start"
      sanitized_query = clazz.try(:sanitized_query, query_string) || query_string
      decompressed_file_path = gz_file_path.gsub(".gz", "")
      File.open(decompressed_file_path, 'wb'){|f| f.write(sanitized_query) }
      puts "#{clazz.table_name} import data start"
      clazz.import_dump_query(decompressed_file_path)
      clazz.remove_file(gz_file_path)
      clazz.remove_file(decompressed_file_path)
      puts "#{clazz.table_name} import completed"
    end
  end

  task generate_to_malkov: :environment do
    natto = Natto::MeCab.new(dicdir: ApplicationRecord::MECAB_NEOLOGD_DIC_PATH)

    {
      TwitterWord => "tweet",
      TwitterWordMention => "tweet",
      Lyric => "body",
      WikipediaArticle => "body"
    }.each do |clazz, word|
      clazz.find_each do |c|
        malkovs = {}
        arr = []
        without_kaomoji_tweet, kaomojis = ApplicationRecord.separate_kaomoji(c.send(word))
        natto.parse(without_kaomoji_tweet) do |n|
          next if n.surface.blank?
          arr << n.surface
        end
        next if arr.blank?
        tris = arr.each_cons(3).map.to_a
        tri_arrs = [["", arr[0..1]].flatten] + tris + [[arr[(arr.size - 2)..(arr.size - 1)] ,""].flatten]
        tri_arrs.each do |tri_arr|
          w = tri_arr.to_a
          tri = malkovs[w]
          if tri.blank?
            malkovs[w] = MarkovTrigram.new(source_type: clazz.to_s, first_gram: w[0].to_s, second_gram: w[1].to_s, third_gram: w[2].to_s, appear_count: 1)
          else
            malkovs[w].appear_count = malkovs[w].appear_count + 1
          end
        end
        MarkovTrigram.import!(malkovs.values, on_duplicate_key_update: "appear_count = appear_count + VALUES(appear_count)")
      end
    end
  end
end
