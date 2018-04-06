class AddColumnsToVideoMeta < ActiveRecord::Migration[5.1]
  def up
    add_column :datapool_video_meta, :original_filename, :string, after: :bitrate
    Datapool::VideoMetum.find_each do |video|
      filename = video.class.match_filename(video.src.to_s)
      video.set_original_filename(filename)
      video.save!
    end
  end

  def down
    remove_column :datapool_video_meta, :original_filename
  end
end
