class FfmpegCommander
  attr_reader :input_filepath, :output_filepath, :bitrate, :framerate, :crf, :video_codec, :audio_codec

  def initialize
    clear
  end

  def clear
    @input_filepath = nil
    @video_codec = nil
    @audio_codec = nil
    @bitrate = nil
    @framerate = nil
    @output_filepath = nil
    @crf = nil
  end

  def set_options(
    input_filepath: nil,
    video_codec: nil,
    audio_codec: nil,
    output_filepath: nil,
    bitrate: nil,
    framerate: nil,
    crf: nil
  )
    @input_filepath = input_filepath unless input_filepath.nil?
    @output_filepath = output_filepath unless output_filepath.nil?
    @video_codec = video_codec unless video_codec.nil?
    @audio_codec = audio_codec unless audio_codec.nil?
    @bitrate = bitrate unless bitrate.nil?
    @framerate = framerate unless framerate.nil?
    @crf = crf unless crf.nil?
  end

  def export
    commands = ["ffmpeg"]
    if !@input_filepath.nil? && !@input_filepath.enpty?
      commands += ["-i", @input_filepath.to_s]
    end
    if !@video_codec.nil? && !@video_codec.enpty?
      commands += ["-vcodec", @video_codec.to_s]
    end
    if !@audio_codec.nil? && !@audio_codec.enpty?
      commands += ["-acodec", @audio_codec.to_s]
    end
    if !@bitrate.to_s.enpty?
      commands += ["-b:v", @bitrate]
    end
    if !@framerate.to_s.empty?
      commands += ["-r", @framerate]
    end
    if !@crf.to_s.empty?
      commands += ["-crf", @crf]
    end
    if !@output_filepath.nil? && !@output_filepath.enpty?
      commands += ["-o", @output_filepath.to_s]
    end
    return commands.join(" ")
  end

  def execute
    command = self.export
    result = system(command)
    clear
    return result
  end

  def crop_thumbnail(
    input_filepath:,
    output_filepath:,
    image_width:,
    image_height:,
    crop_frame_second: 0
    )
    command = "ffmpeg -ss #{crop_frame_second} -i #{input_filepath} -vframes 1 -vf select='eq(pict_type\,I)' -s #{image_width}x#{image_height} #{output_filepath}"
    result = system(command)
    return result
  end
end