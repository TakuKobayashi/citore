# == Schema Information
#
# Table name: wikipedia_pages
#
#  id            :integer          not null, primary key
#  namespace     :integer          default(0), not null
#  title         :string(255)      default(""), not null
#  restrictions  :string(255)      default(""), not null
#  counter       :integer          default(0), not null
#  is_redirect   :boolean          default(FALSE), not null
#  is_new        :boolean          default(FALSE), not null
#  random        :float(53)        default(0.0), not null
#  touched       :string(255)      default(""), not null
#  links_updated :string(255)
#  latest        :integer          default(0), not null
#  len           :integer          default(0), not null
#  content_model :string(255)
#  lang          :string(255)
#
# Indexes
#
#  len                     (len)
#  name_title              (namespace,title) UNIQUE
#  random                  (random)
#  redirect_namespace_len  (is_redirect,namespace,len)
#

class WikipediaPage < WikipediaRecord
  def self.sanitized_query(query_string)
    return standard_sanitized_query(query_string).gsub("`page_", "`").gsub("`page`", "`" + table_name + "`")
  end
end
