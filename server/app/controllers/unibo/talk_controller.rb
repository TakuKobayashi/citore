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
    elsif reading.include?("ナンカサイキンヤルキガオキナインダヨネ")
      return "やらなきゃいけないことがある時ほどやる気が起こらなかったり。"
    elsif reading.start_with?("ヤラナイトイケナイコトハタクサンア")
      return "なんでだろうね？"
    elsif reading.start_with?("ワカラナイ")
      return "そうだよね…"
    elsif reading.start_with?("ヤラナキャイケナイコトヲアトマワシニ")
      return "どうしてそう思う？"
    elsif reading.start_with?("ホントウニダメナニンゲンニオモエテクル")
      return "そっかぁ"
    end
    return nil
  end
end
