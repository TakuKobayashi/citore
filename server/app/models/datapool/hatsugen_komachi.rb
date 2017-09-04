# == Schema Information
#
# Table name: datapool_hatsugen_komachis
#
#  id                :integer          not null, primary key
#  topic_id          :integer          not null
#  res_number        :string(255)      not null
#  top_res_flag      :string(255)      not null
#  title             :string(255)      not null
#  body              :text(65535)
#  handle_name       :string(255)      not null
#  posted_at         :datetime         not null
#  publish_flag      :string(255)      not null
#  parent_topic_flag :string(255)      not null
#  komachi_user_id   :integer          not null
#  advice            :text(65535)
#  funny             :integer          default(0), not null
#  surprise          :integer          default(0), not null
#  tears             :integer          default(0), not null
#  yell              :integer          default(0), not null
#  isee              :integer          default(0), not null
#  genre_code        :string(255)      default(""), not null
#  res_state         :string(255)
#  facemark_id       :string(255)
#  remark            :text(65535)
#  post_device       :string(255)
#
# Indexes
#
#  index_datapool_hatsugen_komachis_on_genre_code               (genre_code)
#  index_datapool_hatsugen_komachis_on_komachi_user_id          (komachi_user_id)
#  index_datapool_hatsugen_komachis_on_posted_at                (posted_at)
#  index_datapool_hatsugen_komachis_on_topic_id_and_res_number  (topic_id,res_number)
#

class Datapool::HatsugenKomachi < ApplicationRecord
  has_many :keywords, class_name: 'Datapool::HatsugenKomachiKeyword', foreign_key: :datapool_hatsugen_komachi_id

  COLUMN_LABELS = {
    topic_id: "トピID",
    res_number: "レスNo",
    top_res_flag: "トピ・レス判定フラグ",
    title: "タイトル",
    body: "本文",
    handle_name: "ハンドルネーム",
    posted_at: "投稿日時",
    publish_flag: "公開状態",
    parent_topic_flag: "親トピ公開状態",
    komachi_user_id: "ユーザーID",
    advice: "備考",
    funny: "面白い",
    surprise: "びっくり",
    tears: "涙ぽろり",
    yell: "なるほど",
    genre_code: "ジャンルコード",
    res_state: "レス受付状態",
    facemark_id: "顔アイコンID",
    remark: "ご意見・ご感想",
    post_device: "投稿デバイス",
  }

  GENRE_CODE_TAG = {
    "01" => "話題",
    "02" => "働く",
    "03" => "健康",
    "04" => "男女",
    "05" => "子供",
    "06" => "ひと",
    "07" => "美",
    "08" => "学ぶ",
    "09" => "口コミ",
    "10" => "編集部",
    "11" => "男性発",
  }

  GENRE_CODE_NAME = {
    "01" => "生活・身近な話題",
    "02" => "キャリア・職場",
    "03" => "心や体の悩み",
    "04" => "恋愛・結婚・離婚",
    "05" => "妊娠・出産・育児",
    "06" => "家族・友人・人間関係",
    "07" => "美容・ファッション・ダイエット",
    "08" => "趣味・教育・教養",
    "09" => "旅行・国内外の地域情報",
    "10" => "編集部からのトピ",
    "11" => "男性から発信するトピ",
  }

  def generate_keywords!
    natto = ApplicationRecord.get_natto
    formats = []
    self.class.natto_text_splitter(put_natto: natto, text: self.body.to_s) do |format|
      formats << format
    end
    # bodyの中の総単語数N
    all_word_count = formats.size.to_f
    komachi_words = Datapool::HatsugenKomachiWord.where(word: formats.map(&:word).uniq).select do |w|
      ["形容詞", "名詞", "動詞"].include?(w.part) && formats.any?{|f| f.word == w.word && f.part == w.part}
    end
    format_groups = formats.group_by{|f| [f.word, f.part] }
    format_groups_tf = {}
    format_groups.each do |word_part, formats|
      format_groups_tf[word_part] = formats.size.to_f / all_word_count
    end

    keywords = komachi_words.sort_by do |w|
      #tf n / N (出現単語数 / 総単語数)
      tfidf = format_groups_tf[[w.word, w.part]].to_f * w.idf.to_f
      -tfidf
    end
    import_keywords = keywords[0..9].map do |k|
      #tf n / N (出現単語数 / 総単語数)
      tf = format_groups_tf[[k.word, k.part]].to_f
      Datapool::HatsugenKomachiKeyword.new(
        datapool_hatsugen_komachi_id: self.id,
        word: k.word,
        part: k.part,
        appear_score: tf * k.appear_idf.to_f,
        tf_idf_score: tf * w.idf.to_f
      )
    end

    Datapool::HatsugenKomachiKeyword.import(import_keywords, on_duplicate_key_update: [:appear_score, :tf_idf_score])
  end

  def self.natto_text_splitter(put_natto: nil, text:)
    if put_natto.blank?
      natto = ApplicationRecord.get_natto
    else
      natto = put_natto
    end
    natto.parse(text) do |n|
      next if n.surface.blank?
      features = n.feature.split(",")
      word = features[6]
      if word.blank? || word == "*"
        word = n.surface
      end
      reading = features[7]
      if reading.blank?
        reading = n.surface
      end
      yield(OpenStruct.new(word: word, part: features[0], reading: reading.to_s))
    end
  end

  def self.import_words!
    natto = ApplicationRecord.get_natto
    self.find_in_batches(batch_size: 10000) do |komachies|
      import_words = []
      appear_imports = {}
      komachies.each do |komachi|
        words = []
        self.natto_text_splitter(put_natto: natto, text: Charwidth.normalize(komachi.body.to_s)) do |format|
          appears = appear_imports[format.word]
          count = 0
          if appears.present?
            count = appears[:appear_count]
          end
          appear_imports[format.word] = {word: format.word, part: format.part, appear_count: count.to_i + 1, reading: format.reading.to_s, type: "Datapool::HatsugenKomachiWord"}
          words << format.word
        end

        words.uniq.each do |w|
          appear_imports[w][:sentence_count] = appear_imports[w][:sentence_count].to_i + 1
        end
      end
      appear_imports.each do |word, hash|
        appear_word = Datapool::AppearWord.new(hash)
        import_words << appear_word
      end
      Datapool::HatsugenKomachiWord.import(import_words, on_duplicate_key_update: "appear_count = appear_count + VALUES(appear_count), sentence_count = sentence_count + VALUES(sentence_count)")
    end
  end
end
