# == Schema Information
#
# Table name: datapool_store_products
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  publisher_name :string(255)
#  product_id     :string(255)      not null
#  title          :string(255)      not null
#  description    :text(65535)
#  url            :text(65535)      not null
#  icon_url       :string(255)
#  review_count   :integer          default(0), not null
#  average_score  :float(24)        default(0.0), not null
#  published_at   :datetime
#  options        :text(65535)
#
# Indexes
#
#  store_product_published_at_index  (published_at)
#  store_product_unique_index        (product_id,type) UNIQUE
#

class Datapool::StoreProduct < ApplicationRecord
  serialize :options, JSON
  has_many :rankings, class_name: 'Datapool::StoreRanking', foreign_key: :datapool_store_product_id
  has_many :reviews, class_name: 'Datapool::Review', foreign_key: :datapool_store_product_id

  def self.update_data!
    Datapool::ItunesStoreApp.update_rankings!
    Datapool::ItunesStoreApp.import_reviews!
    Datapool::GooglePlayApp.update_rankings!
  end

  def self.backup_to_s3
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    database = Shellwords.escape(Regexp.escape(configuration['database'].to_s))
    username = Shellwords.escape(Regexp.escape(configuration['username'].to_s))
    password = Shellwords.escape(Regexp.escape(configuration['password'].to_s))
    tables = [Datapool::StoreProduct, Datapool::StoreRanking, Datapool::Review].map(&:table_name)

    unless Dir.exists?(Rails.root.to_s + "/tmp")
      Dir.mkdir(Rails.root.to_s + "/tmp")
    end
    unless Dir.exists?(Rails.root.to_s + "/tmp/dbdump")
      Dir.mkdir(Rails.root.to_s + "/tmp/dbdump")
    end
    dir_path = Rails.root.to_s + "/tmp/dbdump"

    tables.each do |table|
      cmd = ""
      if password.present?
        cmd += "MYSQL_PWD=#{password} "
      end
      cmd += "mysqldump -u #{username} "
      cmd += "--skip-lock-tables #{database} #{table} > #{dir_path}/#{table}.sql"
      system(cmd)
      puts "#{table} dump complete"
    end

    Zip::File.open(dir_path + "/app_store_product_tables.zip", Zip::File::CREATE) do |zip|
      tables.each do |table|
        File.open("#{dir_path}/#{table}.sql", "rb") do |file|
          zip.get_output_stream("#{table}.sql" ) do |s|
            file.each_line do |line|
              s.write(line)
            end
          end
          puts "#{table} compressed complete"
        end
      end
    end
    puts "compress completed"
    tables.each do |table|
      File.delete("#{dir_path}/#{table}.sql")
    end
    puts "upload start"
    s3 = Aws::S3::Client.new
    File.open(dir_path + "/app_store_product_tables.zip", 'rb') do |zip_file|
      s3.put_object(bucket: "taptappun", body: zip_file,key: "for_send/app_store/app_store_product_tables.zip", acl: "public-read")
    end
    puts "upload completed"
    File.delete(dir_path + "/app_store_product_tables.zip")
    puts "batch completed"
  end
end
