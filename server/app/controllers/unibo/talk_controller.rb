class Unibo::TalkController < BaseController
  protect_from_forgery

  def index
  end

  def input
  end

  def say
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
    elsif reading.include?("サイキンヤルキガオキナインダヨネ")
      return "やらなきゃいけないことがある時ほどやる気が起こらなかったり。"
    elsif reading.include?("ヤラナイトイケナイコトハタクサンア")
      return "なんでだろうね？"
    elsif reading.start_with?("ワカラナイ")
      return "そうだよね…"
    elsif reading.include?("ヤラナキャイケナイコトヲアトマワシニ")
      return "どうしてそう思う？"
    elsif reading.include?("ホントウニダメナニンゲンニオモエテクル")
      return "そういうときもあるよ!"
    end
    return nil
  end
end
