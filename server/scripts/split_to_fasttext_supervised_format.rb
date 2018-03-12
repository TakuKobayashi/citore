natto = TextAnalyzer.get_natto

directory_name = Rails.root.to_s + "/tmp/fasttext_data"
Dir.mkdir(directory_name) unless File.exists?(directory_name)

origin_file_path = Rails.root.to_s + "/tmp/fasttext_data/word.txt"
unless File.exists?(origin_file_path)
  out_file = File.new(origin_file_path,"w")
  out_file.puts("")
  out_file.close
end
origin_file = File.open(origin_file_path,"wb")

train_file_path = Rails.root.to_s + "/tmp/fasttext_data/word_train.txt"
unless File.exists?(train_file_path)
  out_file = File.new(train_file_path,"w")
  out_file.puts("")
  out_file.close
end
train_file = File.open(train_file_path,"wb")

test_file_path = Rails.root.to_s + "/tmp/fasttext_data/word_test.txt"
unless File.exists?(test_file_path)
  out_file = File.new(test_file_path,"w")
  out_file.puts("")
  out_file.close
end
test_file = File.open(test_file_path,"wb")

csv_file = File.read(ARGV[0]).split("\n")

arr = []
csv_file.each do |csv|
  cs = csv.split(",")
  label = "__label__" + cs[0].to_s
  values = []
  natto.parse(cs[1].to_s) do |n|
    values << n.surface
  end
  arr << [label, values.join(" ")].join(",")
end
train_arr, test_arr = arr.partition{|a| 0.9 > rand }

origin_file.write(arr.join("\n"))
train_file.write(train_arr.join("\n"))
test_file.write(test_arr.join("\n"))