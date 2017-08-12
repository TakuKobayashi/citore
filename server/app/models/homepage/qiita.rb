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

class Homepage::Qiita < Homepage::Article
  def self.import_articles!
    client = get_qiita_client
    articles = []
    page_num = 1
    begin
      send_params = {
        per_page: 100,
        page: page_num
      }
      response = client.list_user_items("taptappun", send_params)
      articles = response.body
      instances = articles.map do |article|
        og = OpenGraph.new(article["url"])
        Homepage::Qiita.new(
          uid: article["id"],
          title: article["title"],
          description: article["rendered_body"],
          url: article["url"],
          thumbnail_url: og.images.first,
          pubulish_at: Time.parse(article["created_at"])
        )
      end
      Homepage::Qiita.import(instances, on_duplicate_key_update: [:title, :description, :url, :embed_html, :pubulish_at])
      page_num = page_num + 1
    end while articles.size >= 100
  end

  def self.get_qiita_client
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = Qiita::Client.new(access_token: apiconfig["qiita"]["taptappun"]["accesstoken"])
    return client
  end
end
