class AddColumnToBannosamaGreets < ActiveRecord::Migration[5.1]
  def change
    add_column :bannosama_greets, :audio_upload_url, :string
  end
end
