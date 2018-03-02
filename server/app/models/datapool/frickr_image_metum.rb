# == Schema Information
#
# Table name: datapool_image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  query             :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_image_meta_on_origin_src  (origin_src)
#  index_datapool_image_meta_on_title       (title)
#

class Datapool::FrickrImageMetum < Datapool::ImageMetum
  PER_PAGE = 500

  def self.get_flickr_client
    FlickRaw.api_key = ENV.fetch('FLICKR_APIKEY', '')
    FlickRaw.shared_secret = ENV.fetch('FLICKR_SECRET', '')
    return flickr
  end

  def self.search_images!(search: {})
    flickr_client = self.get_flickr_client
    page_counter = 1
    flickr_images = []
    images = []
    image_counter = 0
    loop do
      flickr_images = flickr_client.photos.search(search.merge({per_page: PER_PAGE, page: page_counter}))
      images += self.generate_images!(flickr_images: flickr_images, options: search)
      page_counter = page_counter + 1
      image_counter += flickr_images.size
      break if image_counter >= flickr_images.total.to_i
    end
    return images.uniq
  end

  private
  def self.generate_images!(flickr_images:, options: {})
    images = []
    image_urls = []
    flickr_image_meta = Datapool::ImageMetum.find_origin_src_by_url(url: flickr_images.map{|f| FlickRaw.url(f) }).index_by(&:src)
    flickr_images.each do |flickr_image|
      image_url = FlickRaw.url(flickr_image)
      next if image_urls.include?(image_url.to_s)
      image_urls << image_url.to_s
      if flickr_image_meta[image_url.to_s].present?
        image = flickr_image_meta[image_url.to_s]
      else
        image = self.constract(
          image_url: image_url.to_s,
          title: ApplicationRecord.basic_sanitize(flickr_image.title),
          options: {
            image_id: flickr_image.id,
            image_secret: flickr_image.secret,
            post_user_id: flickr_image.owner
          }.merge(options)
        )
      end
      images << image
    end
    self.import!(images.select(&:new_record?))

    return images
  end
end
