class CreateVoiceDynamos < ActiveRecord::Migration[5.0]
  def change
    create_table :voice_dynamos do |t|

      t.timestamps
    end
  end
end
