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
  def self.get_flickr_client
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    FlickRaw.api_key = apiconfig["flickr"]["apikey"]
    FlickRaw.shared_secret = apiconfig["flickr"]["secret"]
    return flickr
  end

  def self.import_users_images!(username:)
    flickr_client = self.get_flickr_client
    flickr_user = flickr_client.people.findByUsername(username: username)
    flickr_images = flickr_client.people.getPhotos({user_id: flickr_user["id"], per_page: 500, page: 1})
    images = []
    images += self.generate_images!(flickr_images)
    self.import!(images)
    return images
  end

  def self.search_images!(tags:)
    flickr_client = self.get_flickr_client
    flickr_images = flickr_client.photos.search({tags: tags, per_page: 500, page: 1})
    images = []
    images += self.generate_images!(flickr_images)
    self.import!(images)
    return images
  end

  private
  def self.generate_images!(flickr_images)
    images = []
    image_urls = []
    flickr_images.each do |flickr_image|
      image_url = FlickRaw.url(flickr_image)
      next if image_urls.include?(image_url.to_s)
      image_urls << image_url.to_s
      # 画像じゃないものも含まれていることもあるので分別する
      image_type = FastImage.type(image_url.to_s)
      next if image_type.blank?
      image = self.new(
        title: flickr_image.title,
        options: {
          image_id: flickr_image.id,
          image_secret: flickr_image.secret,
          post_user_id: flickr_image.owner
        }
      )
      image.src = image_url.to_s
      image.original_filename = self.match_image_filename(image.src.to_s)
      images << image
    end

    return images
  end
end
