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
      coulmns = row.split("\t")
      begin
        posted_at = Time.parse(coulmns[6])
      rescue ArgumentError => ex
        puts f
        puts row
        puts ex.message
      end
      next if posted_at.blank?

      arr << Datapool::HatsugenKomachi.new(
        topic_id: coulmns[0],
        res_number: coulmns[1],
        top_res_flag: coulmns[2],
        title: coulmns[3],
        body: coulmns[4],
        handle_name: coulmns[5],
        posted_at: posted_at,
        publish_flag: coulmns[7],
        parent_topic_flag: coulmns[8],
        komachi_user_id: coulmns[9],
        advice: coulmns[10].to_s.strip,
        funny: coulmns[11].to_i,
        surprise: coulmns[12].to_i,
        tears: coulmns[13].to_i,
        yell: coulmns[14].to_i,
        isee: coulmns[15].to_i,
        genre_code: coulmns[16],
        res_state: coulmns[17],
        facemark_id: coulmns[18],
        remark: coulmns[19].to_s.strip,
        post_device: coulmns[20],
      )
    end
    Datapool::HatsugenKomachi.import!(arr)
  end
end