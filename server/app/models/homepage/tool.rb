# == Schema Information
#
# Table name: homepage_tools
#
#  id          :bigint(8)        not null, primary key
#  title       :string(255)
#  description :text(65535)
#  path        :string(255)
#  active      :boolean          default(TRUE), not null
#  pubulish_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_homepage_tools_on_path         (path)
#  index_homepage_tools_on_pubulish_at  (pubulish_at)
#

class Homepage::Tool < ApplicationRecord
  def self.register_tools!
    http_client = HTTPClient.new
    tool_path_methods = Rails.application.routes.named_routes.helper_names.map(&:to_s).select{|s| s.start_with?("tools") && s.include?("path") && !s.include?("root") }
    transaction do
      tool_path_methods.each do |path_method|
        path = Rails.application.routes.url_helpers.send(path_method)
        next if Homepage::Tool.exists?(path: path)
        url = "https://taptappun.net" + path
        response = http_client.get(url)
        next if response.status >= 400
        og = OpenGraph.new(url)
        Homepage::Tool.create!(path: path, pubulish_at: Time.current, title: og.title, description: og.description)
      end
    end
  end

  after_create do
    announcement = Homepage::Announcement.find_or_initialize_by(from: self)
    announcement.update!(
      title: self.title.to_s + "を作成しました",
      description: self.description,
      url: self.path,
      pubulish_at: self.pubulish_at
    )
  end
end
