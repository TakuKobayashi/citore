natto = ApplicationRecord.get_natto

directory_name = Rails.root.to_s + "/tmp/seq2seq_data"
Dir.mkdir(directory_name) unless File.exists?(directory_name)

input_file_path = Rails.root.to_s + "/tmp/seq2seq_data/tweet_input.txt"
unless File.exists?(input_file_path)
  out_file = File.new(input_file_path,"w")
  out_file.puts("")
  out_file.close
end
input_file = File.new(input_file_path,"a")

output_file_path = Rails.root.to_s + "/tmp/seq2seq_data/tweet_input.txt"
unless File.exists?(output_file_path)
  out_file = File.new(output_file_path,"w")
  out_file.puts("")
  out_file.close
end
output_file = File.new(output_file_path,"a")

TwitterWord.preload(:parent).find_each do |tw|
  if tw.parent.present?
    outs = []
    natto.parse(tw.tweet) do |no|
      if no.surface.present?
        outs << no.surface
      end
    end
    ins = []
    natto.parse(tw.parent.tweet) do |ni|
      if ni.surface.present?
        ins << ni.surface
      end
    end
    output_file.puts(outs.join(" "))
    input_file.puts(ins.join(" "))
  end
end