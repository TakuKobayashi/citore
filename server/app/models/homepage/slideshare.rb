# == Schema Information
#
# Table name: homepage_articles
#
#  id            :integer          not null, primary key
#  type          :string(255)
#  uid           :string(255)      not null
#  title         :string(255)      not null
#  description   :text(65535)
#  url           :string(255)      not null
#  embed_html    :text(65535)
#  thumbnail_url :string(255)
#  active        :boolean          default(TRUE), not null
#  pubulish_at   :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_homepage_articles_on_pubulish_at  (pubulish_at)
#  index_homepage_articles_on_uid          (uid) UNIQUE
#

class Homepage::Slideshare < Homepage::Article
def self.import_articles!
    client = get_slideshare_client
    articles = []
    page_num = 1
    begin
      send_params = {
        user: "takukobayashi560",
        per_page: 50,
        page: page_num
      }
      articles = client.slideshows(send_params)
      instances = articles.map do |article|
        og = OpenGraph.new(article.url)
        Homepage::Slideshare.new(
          uid: article.id.to_s,
          title: article.title,
          description: article.description,
          url: article.url,
          embed_html: article.embed,
          thumbnail_url: og.images.first,
          pubulish_at: article.created_at
        )
      end
      Homepage::Slideshare.import(instances, on_duplicate_key_update: [:title, :description, :url, :embed_html, :pubulish_at])
      page_num = page_num + 1
    end while articles.size >= 50
  end

  def self.get_slideshare_client
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = SlideshareApi::Client.new(apiconfig["slideshare"]["apikey"], apiconfig["slideshare"]["shared_secret"])
    return client
  end
end
