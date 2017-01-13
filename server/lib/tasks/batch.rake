require 'google/apis/youtube_v3'

namespace :batch do

  task :export_to_csv_from_dynamodb, :environment do
    Aws.config.update(Rails.application.config_for(:aws).symbolize_keys)
    table_name = ARGV.last
    client = Aws::DynamoDB::Client.new
    start_key = nil
    counter = 0
    CSV.open(Rails.root.to_s + "/tmp/" + table_name + ".csv", "wb") do |csv|
      results = []
      begin
        counter += 1
        results = client.scan(table_name: table_name, limit: 500, exclusive_start_key: start_key)
        results.items.each_with_index do |hash, index|
          if index == 0 && start_key.blank?
            csv << hash.keys
          end
          values = hash.values
          csv << values.map do |v|
            if v.instance_of?(Array) || v.instance_of?(Hash)
              v.to_json
            else
              v.to_s
            end
          end
        end
        puts "#{counter}:#{results.count}:#{results.last_evaluated_key}"
        start_key = results.last_evaluated_key
      end while start_key.present?
    end
    # 空タスク作ってエラーを握りつぶす
    ARGV.slice(1,ARGV.size).each{|v| task v.to_sym do; end}
  end

  task import_sql_from_wikipedia: :environment do
    [
        [WikipediaTopicCategory, "jawiki-latest-category.sql.gz"],
        [WikipediaPage, "jawiki-latest-page.sql.gz"]
#        [WikipediaCategoryPage, "jawiki-latest-categorylinks.sql.gz"]
    ].each do |clazz, file_name|
      puts "#{clazz.table_name} download start"
      gz_file_path = clazz.download_file(file_name)
      puts "#{clazz.table_name} decompress start"
      query_string = clazz.decompress_gz_query_string(gz_file_path)
      puts "#{clazz.table_name} save file start"
      sanitized_query = clazz.try(:sanitized_query, query_string) || query_string
      decompressed_file_path = gz_file_path.gsub(".gz", "")
      File.open(decompressed_file_path, 'wb'){|f| f.write(sanitized_query) }
      puts "#{clazz.table_name} import data start"
      clazz.import_dump_query(decompressed_file_path)
      clazz.remove_file(gz_file_path)
      clazz.remove_file(decompressed_file_path)
      puts "#{clazz.table_name} import completed"
    end
  end
end
