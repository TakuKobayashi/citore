# == Schema Information
#
# Table name: datapool_websites
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  title      :string(255)      not null
#  origin_src :string(255)      not null
#  query      :text(65535)
#  options    :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_origin_src  (origin_src)
#  index_datapool_websites_on_title       (title)
#

class Datapool::Website < ApplicationRecord
  serialize :options, JSON

  def src
    url = Addressable::URI.parse(self.origin_src)
    url.query = self.query
    return url.to_s
  end

  def src=(url)
    aurl = Addressable::URI.parse(url)
    pure_url = aurl.origin.to_s + aurl.path.to_s
    if pure_url.size > 255
      word_counter = 0
      srces, other_pathes = pure_url.split("/").partition do |word|
        word_counter = word_counter + word.size + 1
        word_counter <= 255
      end
      self.origin_src = srces.join("/")
      self.query = other_pathes.join("/") + aurl.query.to_s
    else
      self.origin_src = pure_url
      self.query = aurl.query
    end
  end

  def self.constract(url:, title: "", options: {})
    website = self.new(
      title: title,
      options: {
      }.merge(options)
    )
    website.src = url
    return website
  end
end
