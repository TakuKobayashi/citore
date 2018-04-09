class FfmpegCommander
  attr_reader :input_filepath, :output_filepath, :video_codec, :bitrate, :framerate, :audio_codec

  def initialize
    @input_filepath = nil
    @video_codec = nil
    @audio_codec = nil
    @bitrate = nil
    @framerate = nil
    @output_filepath = nil
  end

  def set_input_filepath(input_filepath)
    @input_filepath = input_filepath
  end

  def set_video_codec(codec)
    @video_codec = codec
  end

  def set_audio_codec(codec)
    @audio_codec = codec
  end

  def set_output_filepath(output_filepath)
    @output_filepath = output_filepath
  end

  def set_bitrate(bitrate)
    @bitrate = bitrate
  end

  def set_framerate(framerate)
    @framerate = framerate
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
    if !@output_filepath.nil? && !@output_filepath.enpty?
      commands += ["-o", @output_filepath.to_s]
    end
    return commands.join(" ")
  end

  def execute
    command = self.export
    system(command)
  end
end