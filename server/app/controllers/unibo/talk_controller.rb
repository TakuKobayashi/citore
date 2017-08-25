class Unibo::TalkController < BaseController
  protect_from_forgery

  def index
  end

  def input
  end

  def say
    word = params[:word]
    res_word = dummy_res
    if res_word.blank?
      data = Datapool::HatsugenKomachi.find_by(id: rand(Datapool::HatsugenKomachi.count) + 1)
      res_word = data.try(:title)
    end
    render :json => res_word
  end

  private
  def dummy_res
    word = params[:word].to_s
    reading = ApplicationRecord.reading(word)
    if reading.start_with?("ハァ")
      return "どうしたの？"
    elsif reading.start_with?("ナンカサイキンヤルキガオキナインダヨネイエニイルトキハダイタイネットサーフィンシテルカソシャゲシテルダケダシ")
      return "家にいるとついダラダラとネットサーフィンしちゃうよね。やらなきゃいけないことがある時ほどやる気が起こらなかったり。"
    elsif reading.start_with?("ソウナンダヨヤラナイトイケナイコトハタクサンアッテナノニダラダラシチャウヤラナキャイケナイコトヲアトマワシニシテルトジブンガホントウニダメナニンゲンニオモエテクル")
      return "なんでだろうね？"
    elsif reading.start_with?("ワカラナイ")
      return "そうだよね…"
    elsif reading.start_with?("デモヤラナキャイケナイコトガアルトキホドヤルキガオコラナイッテノハホントウニソウナンダヨナァコンカイモレポートノテイシュツガアトニシュウカンダッテオモッタラナンカキュウニナニモヤリタクナクナッテキチャッテ")
      return "どうしてそう思う？"
    elsif reading.start_with?("ドウシテッテ…ヤラナキャイケナイコトカラニゲテアソンジャッテルカラソリャジブンハダメニンゲンダッテオモッチャウヨ")
      return "そっかぁ"
    end
    return nil
  end
end
