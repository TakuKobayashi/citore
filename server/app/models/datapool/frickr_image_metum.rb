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
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    FlickRaw.api_key = apiconfig["flickr"]["apikey"]
    FlickRaw.shared_secret = apiconfig["flickr"]["secret"]
    return flickr
  end

  def self.import_users_images!(username:)
    flickr_client = self.get_flickr_client
    flickr_user = nil
    begin
      flickr_user = flickr_client.people.findByUsername(username: username)
    rescue FlickRaw::FailedResponse => e
      Rails.logger.info "unknown user"
    end
    return [] if flickr_user.nil?
    page_counter = 1
    flickr_images = []
    images = []
    loop do
      flickr_images = flickr_client.people.getPhotos({user_id: flickr_user["id"], per_page: PER_PAGE, page: page_counter})
      images += self.generate_images!(flickr_images: flickr_images)
      page_counter = page_counter + 1
      break if flickr_images.size < PER_PAGE
    end
    return images
  end

  def self.search_images!(text:)
    flickr_client = self.get_flickr_client
    page_counter = 1
    flickr_images = []
    images = []
    loop do
      flickr_images = flickr_client.photos.search({text: text, per_page: PER_PAGE, page: page_counter})
      images += self.generate_images!(flickr_images: flickr_images, options: {keyword: text})
      page_counter = page_counter + 1
      break if flickr_images.size < PER_PAGE
    end
    return images
  end

  private
  def self.generate_images!(flickr_images:, options: {})
    images = []
    image_urls = []
    flickr_images.each do |flickr_image|
      image_url = FlickRaw.url(flickr_image)
      next if image_urls.include?(image_url.to_s)
      image_urls << image_url.to_s
      image = self.constract(
        image_url: image_url.to_s,
        title: flickr_image.title,
        options: {
          image_id: flickr_image.id,
          image_secret: flickr_image.secret,
          post_user_id: flickr_image.owner
        }.merge(options)
      )
      images << image
    end
    self.import!(images)

    return images
  end
end
