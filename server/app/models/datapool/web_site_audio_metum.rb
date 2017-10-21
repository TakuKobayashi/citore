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
  # audioタグがそんなにあるわけではないので、そのサイト内にあるリンク先までにある音声ファイル全てを保存していく
  def self.suppress_to_children!(url:, page_key: nil, start_page: 1, end_page: 1)
    all_audios = []
    (start_page.to_i..end_page.to_i).each do |page|
      address_url = Addressable::URI.parse(url.to_s)
      if page_key.present?
        queries = address_url.query_values || {}
        address_url.query_values = queries.merge(page_key => page)
      end
      break unless address_url.scheme.to_s.include?("http")
      target_urls = [address_url.to_s]
      target_urls += self.select_link_urls(url: address_url.to_s)
      loop do
        crawl_url = target_urls.shift
        Rails.logger.info crawl_url.to_s
        doc = ApplicationRecord.request_and_parse_html(url: crawl_url.to_s)
        all_audios += self.analize_and_import_audio!(url: crawl_url.to_s, options: {root_from_url: url.to_s})
        break if target_urls.blank?
      end
    end
    all_audios.uniq!(&:src)
    if all_audios.present?
      src_audios = Datapool::AudioMetum.find_origin_src_by_url(url: all_audios.map(&:src)).index_by(&:src)
      import_audios = all_audios.select{|audio| src_audios[audio.src].blank? }
      if import_audios.present?
        Datapool::WebSiteAudioMetum.import!(import_audios)
      end
    end
    return all_audios
  end

  def self.select_link_urls(url:)
    urls = []
    crawl_url = Addressable::URI.parse(url.to_s)
    doc = ApplicationRecord.request_and_parse_html(url: crawl_url.to_s)
    doc.css("a").each do |a|
      link_url = Addressable::URI.parse(ApplicationRecord.merge_full_url(src: URI.encode(a["href"].to_s), org: crawl_url.to_s))
      if crawl_url.host == link_url.host && link_url.scheme.to_s.include?("http")
        urls << link_url.to_s
      end
    end
    return urls
  end

  def self.analize_and_import_audio!(url:, options: {})
    audios = []
    crawl_url = Addressable::URI.parse(url.to_s)
    doc = ApplicationRecord.request_and_parse_html(url: crawl_url.to_s)
    doc.css("audio").each do |audio_doc|
      audio_url = Addressable::URI.parse(ApplicationRecord.merge_full_url(src: audio_doc["src"].to_s, org: crawl_url.to_s))
      audio_metum = Datapool::WebSiteAudioMetum.new(
        title: doc.title,
        file_genre: :audio_file,
        options: options.merge({from_url: crawl_url.to_s})
      )
      audio_metum.src = audio_url.to_s
      audios << audio_metum
    end
    return audios
  end
end