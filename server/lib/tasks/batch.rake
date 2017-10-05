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
      loop do
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
        break if start_key.blank?
      end
    end
    # 空タスク作ってエラーを握りつぶす
    ARGV.slice(1,ARGV.size).each{|v| task v.to_sym do; end}
  end

  task import_to_appear_word: :environment do
    sum_count = ExtraInfo.read_extra_info["sum_sentence_count"].to_i
    natto = ApplicationRecord.get_natto
    {
      TwitterWord => "tweet"
    }.each do |activerecord_clazz, field_name|
      activerecord_clazz.find_in_batches do |clazzes|
        import_words = []
        appear_imports = {}
        clazzes.each do |clazz|
          sanitaized_word = ApplicationRecord.basic_sanitize(clazz.send(field_name))
          without_url, urls = ApplicationRecord.separate_urls(sanitaized_word)

          words = []
          natto.parse(without_url) do |n|
            next if n.surface.blank?
            features = n.feature.split(",")
            part = EmotionalWord::PARTS[features[0]]
            next if part.blank? || part == "av"
            word = features[6]
            if word.blank? || word == "*"
              word = n.surface
            end
            appears = appear_imports[word]
            if appears.present?
              count = appears[:appear_count]
            end
            appear_imports[word] = {word: word, part: part, appear_count: count.to_i + 1}
            words << word
          end

          words.uniq.each do |w|
            appear_imports[w][:sentence_count] = appear_imports[w][:sentence_count].to_i + 1
          end
        end

        appear_imports.each do |word, hash|
          appear_word = Datapool::AppearWord.new(hash)
          import_words << appear_word
        end
        Datapool::AppearWord.import(import_words, on_duplicate_key_update: "appear_count = appear_count + VALUES(appear_count), sentence_count = VALUES(sentence_count)")
        sum_count = sum_count + import_words.size
        ExtraInfo.update({"sum_sentence_count" => sum_count})
      end
    end
  end

  task import_to_similar_word: :environment do
    similar_id = ExtraInfo.read_extra_info["similar_metadata"]
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    parts = EmotionalWord::PARTS.values
    Datapool::AppearWord.where(part: parts).where("id > ?", similar_id.to_i).find_in_batches do |appears|
      appears.each do |appear|
        list = `http -a #{apiconfig["metadata_wordassociator"]["username"]}:#{apiconfig["metadata_wordassociator"]["password"]} GET wordassociator.ap.mextractr.net/word_associator/api_query query==#{appear.word}`
        word_score_list = JSON.parse(list).map{|l| [ApplicationRecord.basic_sanitize(l[0].encode("UTF-8")), l[1]] }
        next if word_score_list.blank?
        values = word_score_list.map{|word, score| "(" + ["NULL", 1, "'#{word}'", "'#{appear.part}'"].join(",") + ")" }
        sql = "INSERT INTO `#{Datapool::AppearWord.table_name}` (#{Datapool::AppearWord.column_names.join(',')}) VALUES " + values.join(",") + " ON DUPLICATE KEY UPDATE `#{Datapool::AppearWord.table_name}`.`word` = VALUES(`word`)"
        Datapool::AppearWord.connection.execute(sql)
        word_ids = Datapool::AppearWord.where(word: word_score_list.map{|w| w[0] }, part: appear.part).pluck(:word, :id)

        similar_values = word_score_list.map do |word, score|
          w_id = word_ids.detect{|w, id| w == word }
          if w_id.blank?
            nil
          else
            "(" + ["NULL", appear.id, w_id[1], score, "'metadata'"].join(",") + ")"
          end
        end.compact
        similar_sql = "INSERT INTO `#{SimilarWord.table_name}` (#{SimilarWord.column_names.join(',')}) VALUES " + similar_values.join(",") + " ON DUPLICATE KEY UPDATE `#{SimilarWord.table_name}`.`to_word_id` = VALUES(`to_word_id`)"
        SimilarWord.connection.execute(similar_sql)
      end
      ExtraInfo.update({"similar_metadata" => appears.last.try(:id)})
    end
  end

  task import_to_dynamodb_from_table: :environment do
    Aws.config.update(Rails.application.config_for(:aws).symbolize_keys)
    client = Aws::DynamoDB::Client.new
    {
      TwitterWord => "TwitterWordDynamo",
      Datapool::AppearWord => "AppearWordDynamo",
      MarkovTrigram => "MarkovTrigramDynamo",
    }.each do |activerecord_clazz, dynamodb_tablename|
      activerecord_clazz.find_in_batches do |clazzes|
        clazzes.each_slice(25) do |records|
          ApplicationRecord.batch_execution_and_retry do
            client.batch_write_item({
              request_items: {
                dynamodb_tablename => records.map{|r| {put_request: {item: r.attributes} } }
              }
            })
          end
        end
      end
    end
  end

  task rebuild_twitter_replay_id: :environment do
    tweet_id = ExtraInfo.read_extra_info["rebuild_tweet_id"]
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client =  TwitterRecord.get_twitter_rest_client("citore")
    limit_span = (15.minutes.second / 120).to_i
    TwitterWord.where("id > ?", tweet_id.to_i).find_in_batches do |words|
      words.each_slice(100) do |w|
        ApplicationRecord.batch_execution_and_retry(sleep_second: 900) do
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
        end
      end
      ExtraInfo.update({"rebuild_tweet_id" => words.last.id})
    end
  end

  task import_line_sticker: :environment do
    LineSticker.connection.execute("TRUNCATE TABLE #{LineSticker.table_name}")
    stickers = []
    p "generate start"
    CSV.foreach(Rails.root.to_s + "/db/master_data/line_sticker.csv", headers: true) do |data|
      stickers << LineSticker.new(stkid: data["STKID"], stkpkgid: data["STKPKGID"], stkver: data["STKVER"], meaning: "")
    end
    p "data row #{stickers.size}"
    LineSticker.import(stickers)
  end

  task import_emotional_word: :environment do
    EmotionalWord.connection.execute("TRUNCATE TABLE #{EmotionalWord.table_name}")
    dics = []
    en = File.read(Rails.root.to_s + "/db/master_data/pn_en.dic")
    ens = en.split("\n")
    ews = ens.map do |e|
      es = e.split(":")
      EmotionalWord.new(word: es[0], reading: es[0], part: es[1],score: es[2].to_f, language: 1)
    end
    p "es import start"
    EmotionalWord.import(ews, on_duplicate_key_update: [:word, :reading, :part])
    ens_average_score = EmotionalWord.english.average(:score)

    
    parts = EmotionalWord::PARTS
    ja = File.read(Rails.root.to_s + "/db/master_data/pn_ja.dic")
    jas = ja.split("\r\n")
    jws = jas.map do |j|
      js = j.split(":")
      word = ApplicationRecord.basic_sanitize(js[0])
      reading = js[1].tr('ぁ-ん','ァ-ン')
      EmotionalWord.new(word: word, reading: reading, part: parts[js[2]],score: js[3].to_f, language: 0)
    end
    p "js import start"
    EmotionalWord.import(jws, on_duplicate_key_update: [:word, :reading, :part])
    jas_average_score = EmotionalWord.japanese.average(:score)
    hash = {}
    hash[:en_average_score] = ens_average_score
    hash[:ja_average_score] = jas_average_score
    ExtraInfo.update(hash)
  end

  task delete_double_tweet: :environment do
    logger = ActiveSupport::Logger.new("log/deleted.log")
    console = ActiveSupport::Logger.new(STDOUT)
    logger.extend ActiveSupport::Logger.broadcast(console)
    TwitterWord.find_each do |word|
      tweets = TwitterWord.where(twitter_tweet_id: word.twitter_tweet_id).to_a
      if tweets.size > 1
        message = CSV.generate do |csv|
          tweets.each do |t|
            csv << t.attributes.values
          end
        end
        logger.info(message)
        TwitterWord.where(twitter_tweet_id: word.twitter_tweet_id).where.not(id: word.id).delete_all
      end
    end
  end

  task get_reply_tweet: :environment do
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client =  TwitterRecord.get_twitter_rest_client("citore")
    limit_span = (15.minutes.second / 120).to_i
    TwitterWord.find_in_batches do |words|
      reply_tweet_ids = []
      words.each do |w|
        if w.reply_to_tweet_id.present?
          reply_tweet_ids << w.reply_to_tweet_id
        end
      end
      ApplicationRecord.batch_execution_and_retry(sleep_second: 900) do
        tws = []
        tweets = client.statuses(reply_tweet_ids)
        tweets.each do |status|
          sanitaized_word = TwitterRecord.sanitized(status.text)
          without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)
          t = TwitterWord.new(
            twitter_user_id: status.user.id.to_s,
            twitter_user_name: status.user.screen_name.to_s,
            twitter_tweet_id: status.id.to_s,
            tweet: without_url_tweet,
            csv_url: urls.join(","),
            tweet_created_at: status.created_at,
            reply_to_tweet_id: status.in_reply_to_status_id.to_s
          )
          tws << t
        end
        TwitterWord.import(tws, on_duplicate_key_update: [:in_reply_to_status_id])
      end
      sleep limit_span
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
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    natto = ApplicationRecord.get_natto
    {
      #TwitterWord => "tweet",
      #Lyric => "body"
      CharacterSerif => "body"
    }.each do |clazz, word|
      last_saved_id = ExtraInfo.read_extra_info[(clazz.to_s + "_malkov")]
      cached_hash_id = {}
      clazz.where("id > ?", last_saved_id.to_i).find_in_batches do |cs|
        batch_words = []
        ApplicationRecord.batch_execution_and_retry do
          cs.each do |c|
            if clazz == Lyric
              split_list = c.send(word).to_s.split("\n").map(&:strip)
            else
              split_list = [c.send(word).to_s]
            end
            split_list.each do |cell|
              arr = []
              sanitaized_word = TwitterRecord.sanitized(cell)
              without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)
              without_kaomoji_tweet, kaomojis = ApplicationRecord.separate_kaomoji(without_url_tweet)
              natto.parse(without_kaomoji_tweet.downcase) do |n|
                next if n.surface.blank?
                arr << n.surface
              end
              words = arr.map{|t| ApplicationRecord.delete_symbols(t) }.select{|t| t.present? }.each_cons(3).map.to_a
              next if words.blank?
              batch_words << words
            end
          end
          malkov_prefixes = {}
          malkov_words = {}
          is_load_words = false
          batch_words.each do |words|
            words.each_with_index do |w, index|
              if index == 0
                state = MarkovTrigramPrefix.states[:bos]
              elsif index == words.size - 1
                state = MarkovTrigramPrefix.states[:eos]
              else
                state = MarkovTrigramPrefix.states[:normal]
              end

              key = [w[0].to_s, state]
              malkov = malkov_prefixes[key]
              if malkov.blank?
                malkov = MarkovTrigramPrefix.new(source_type: clazz.to_s, prefix: w[0].to_s, state: state, unique_count: 1)
              end
              malkov.sum_count += 1
              malkov_prefixes[key] = malkov

              malkov_word = malkov_words[key]
              if malkov_word.blank?
                malkov_word = MarkovTrigramWord.new(second_word: w[1], third_word: w[2])
              end
              malkov_word.appear_count += 1
              malkov_words[key] = malkov_word
              if cached_hash_id[key].blank?
                is_load_words = true
              end
            end
          end
          key_prefixes = {}
          MarkovTrigramPrefix.import!(malkov_prefixes.values, on_duplicate_key_update: [:unique_count, :sum_count])
          if is_load_words
            key_prefixes = MarkovTrigramPrefix.where(source_type: clazz.to_s, prefix: malkov_prefixes.keys.map{|w, s| w }).index_by{|pref| [pref.prefix, MarkovTrigramPrefix.states[pref.state]] }
          else
            malkov_prefixes.each do |k, v|
              key_prefixes[k] = cached_hash_id[k]
            end
          end
          key_prefixes.each do |key, pref|
            r_id = pref.try(:id) || pref
            malkov_w = malkov_words[key]
            next if malkov_w.blank?
            malkov_w.markov_trigram_prefix_id = r_id
            malkov_words[key] = malkov_w
          end
          MarkovTrigramWord.import!(malkov_words.values.select{|m| m.markov_trigram_prefix_id.present? }, on_duplicate_key_update: [:appear_count])
        end
        ExtraInfo.update({(clazz.to_s + "_malkov") => cs.last.try(:id)})
      end
    end
    ActiveRecord::Base.logger = old_logger
  end

  task resanitized: :environment do
    TwitterWord.find_in_batches do |ts|
      TwitterWord.transaction do
        ts.each do |t|
          t.update(tweet: ApplicationRecord.basic_sanitize(t.tweet))
        end
      end
    end
  end

  task upload_s3: :environment do
    s3 = Aws::S3::Client.new
    File.open(ARGV.last, 'rb') do |file|
      s3.put_object(bucket: "taptappun",body: file,key: "project/backup/" + File.basename(ARGV.last), acl: "public-read")
    end
  end

  task komachi_sanitize: :environment do
    Datapool::AppearWord.find_each do |aw|
      word = Charwidth.normalize(aw.word.to_s)
      if aw.word.to_s != word
        same_aw = Datapool::AppearWord.find_by(word: word, part: aw.part)
        Datapool::AppearWord.transaction do
          if same_aw.present?
            same_aw.destroy
          end
          aw.update(word: word)
        end
      end
    end
  end

  task komachi_keywords: :environment do
    Datapool::HatsugenKomachi.find_each do |komachi|
      komachi.generate_keywords!
    end
  end

  task generate_komachi_res_set: :environment do
    natto = ApplicationRecord.get_natto
    topic_id_count = Datapool::HatsugenKomachi.group(:topic_id).count
    out_file = File.new(Rails.root.to_s + LEARNING_TXT_FILE_PATH, "w")
    topic_id_count.each do |topic_id, count|
      next if count <= 1
      komachies = Datapool::HatsugenKomachi.where(topic_id: topic_id).sort_by{|k| k.res_number.to_i }
      topic = komachies.first
      reses = komachies[1..(komachies.size)]
      reses.each do |res|
#      komachies.each_cons(2) do |topic, res|
        line = ""
        nres = []
        topic_keywords = []
        natto.parse(ApplicationRecord.basic_sanitize(topic.body)) do |n|
          next if n.surface.to_s.strip.blank? || !["動詞", "形容詞", "名詞"].include?(n.feature.split(",").first)
          topic_keywords << n.surface.to_s
        end
        topic_keywords.shuffle!
        topic_keywords.uniq[0..9].each do |word|
          line += "__label__" + word + ", "
        end
        natto.parse(ApplicationRecord.basic_sanitize(res.body)) do |n|
          nres << n
        end
        line += nres.map{|res| res.surface }.join(" ")
        out_file.puts(line)
      end
    end
    out_file.close
  end
end
