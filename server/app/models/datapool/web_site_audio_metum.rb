# == Schema Information
#
# Table name: datapool_audio_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  file_genre        :integer          default("audio_file"), not null
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  query             :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_audio_meta_on_origin_src  (origin_src)
#  index_datapool_audio_meta_on_title       (title)
#

class Datapool::WebSiteAudioMetum < Datapool::AudioMetum
  # audioタグがそんなにあるわけではないので、そのサイトにある音声ファイル全てを抑えにいく勢い
  def self.suppress!(url:)
    audios = []
    audio_urls = []
    target_urls = []
    crawl_urls = []
    root_crawl_url = Addressable::URI.parse(url.to_s)
    crawl_url = root_crawl_url.origin
    loop do
      doc = ApplicationRecord.request_and_parse_html(crawl_url.to_s)
      doc.css("a").each do |a|
        link_url = Addressable::URI.parse(ApplicationRecord.merge_full_url(src: a["href"], org: root_crawl_url.to_s))
        if root_crawl_url.host == link_url.host && !crawl_urls.include?(link_url.to_s)
          crawl_urls << link_url.to_s
          target_urls << link_url.to_s
        end
      end
      doc.css("audio").each do |audio_doc|
        audio_url = ApplicationRecord.merge_full_url(src: audio_doc["src"].to_s, org: root_crawl_url.to_s)
        next if audio_urls.include?(audio_url.to_s)
        audio_urls << audio_url.to_s
        audio_metum = Datapool::WebSiteAudioMetum.new(
          title: doc.title,
          file_genre: :audio_file,
          options: {root_from_url: url, from_url: crawl_url.to_s}
        )
        audio_metum.src = audio_url.to_s
        audios << audio_metum
      end
      break if target_urls.blank?
      crawl_url = target_urls.shift
    end
    audios.uniq!(&:src)
    src_audios = Datapool::AudioMetum.find_origin_src_by_url(url: audios.map(&:src)).index_by(&:src)
    import_audios = audios.select{|audio| src_audios[audio.src].blank? }
    if import_audios.present?
      Datapool::WebSiteAudioMetum.import!(import_audios)
    end
    return audios
  end
end