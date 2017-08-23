class CreateDatapoolHatsugenKomachis < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_hatsugen_komachis do |t|
      t.integer :topic_id, null: false
      t.string :res_number, null: false
      t.string :top_res_flag, null: false
      t.string :title, null: false
      t.text :body
      t.string :handle_name, null: false
      t.datetime :posted_at, null: false
      t.string :publish_flag, null: false
      t.string :parent_topic_flag, null: false
      t.integer :komachi_user_id, limit: 8, null: false
      t.text :advice
      t.string :post_device, null: false
      t.text :remark

#      トピID	レスNo	トピ・レス判定フラグ	タイトル	本文	ハンドルネーム	投稿日時
#      公開状態	親トピ公開状態	ユーザーID	備考	面白い	びっくり	涙ぽろり	エール	なるほど	ジャンルコード	レス受付状態	顔アイコンID	ご意見・ご感想	投稿デバイス	メールアドレス(PCのみ)	パスワード(PCのみ)	UID(モバイルのみ)
    end
  end
end
