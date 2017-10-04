files = Dir.glob(Rails.root.to_s + "/data/**/*").select{|file| File.file?(file) && File.extname(file) == ".txt" }
files.each do |f|
  tsv = File.read(f, encoding: "Shift_JIS:UTF-8", undef: :replace, replace: "*")
  rows = tsv.split(/\n|\r\n/)
  rows = rows[1..(rows.size)]
  puts rows.size
  counter = 0
  rows.each_slice(10000) do |r|
    arr = []
    puts counter.to_s
    counter = counter + 1
    r.each do |row|
      columns = row.split("\t")
      begin
        posted_at = Time.parse(columns[6])
      rescue ArgumentError => ex
        puts f
        puts row
        puts ex.message
      end
      next if posted_at.blank?

      arr << Datapool::HatsugenKomachi.new(
        topic_id: columns[0],
        res_number: columns[1],
        top_res_flag: columns[2],
        title: columns[3],
        body: columns[4],
        handle_name: columns[5],
        posted_at: posted_at,
        publish_flag: columns[7],
        parent_topic_flag: columns[8],
        komachi_user_id: columns[9],
        advice: columns[10].to_s.strip,
        funny: columns[11].to_i,
        surprise: columns[12].to_i,
        tears: columns[13].to_i,
        yell: columns[14].to_i,
        isee: columns[15].to_i,
        genre_code: columns[16],
        res_state: columns[17],
        facemark_id: columns[18],
        remark: columns[19].to_s.strip,
        post_device: columns[20],
      )
    end
    Datapool::HatsugenKomachi.import!(arr)
  end
end