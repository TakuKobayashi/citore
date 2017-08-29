class CreateDatapoolHatsugenKomachiKeywords < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_hatsugen_komachi_keywords do |t|
      t.integer :datapool_hatsugen_komachi_id, null: false
      t.string  :word, null: false
      t.string  :part, null: false
      t.float :appear_score, null: false, default: 0
      t.float :tf_idf_score, null: false, default: 0
    end
    add_index :datapool_hatsugen_komachi_keywords, [:datapool_hatsugen_komachi_id, :word, :part], name: "keywords_hatsugen_komachi_unique_index"
    add_index :datapool_hatsugen_komachi_keywords, [:word, :part], name: "keywords_hatsugen_komachi_word_part_index"
  end
end
