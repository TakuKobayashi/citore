# == Schema Information
#
# Table name: homepage_products
#
#  id          :integer          not null, primary key
#  category    :integer          default(0), not null
#  title       :string(255)
#  html_body   :text(65535)      not null
#  url         :string(255)
#  pubulish_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Homepage::Product < ApplicationRecord
end
