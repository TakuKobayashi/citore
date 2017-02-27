others = []
(1..4).each do |i|
  arr = []
  csv = File.read(Rails.root.to_s + "/2017022#{i}_reply.csv")
  cs = csv.split("\n")
  columns = cs[0].split(",")
  p cs.size
  cs[1..(cs.size - 1)].each do |c|
  	cells = c.split(",")
  	next if cells.blank?
  	if cells.size != 7
  	  others << [cells[0..4],cells[5..(cells.size - 2)].try(:join, ".").to_s,cells[(cells.size - 2)..(cells.size - 1)]].flatten.join(",")
  	  next
    end
    tw = TwitterWord.new
    columns.each_with_index do |column, index|
      if index == 5
        tw.send(column + "=", Time.parse(cells[index]))
      else
        tw.send(column + "=", cells[index])
      end
    end
    arr << tw
  end
  p arr.size
  arr.each_slice(1000) do |ar|
  	begin
      TwitterWord.import(ar, on_duplicate_key_update: [:twitter_tweet_id])
    rescue
      others += ar.map do |a|
        csv = []
        columns.map{|c| a.send(c) }.join(",")
      end
    end
  end
end
File.open(Rails.root.to_s + "/others.csv", "wb"){|f| f.write(others.join("\n")) }