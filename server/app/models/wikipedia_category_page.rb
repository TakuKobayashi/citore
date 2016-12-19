# == Schema Information
#
# Table name: wikipedia_category_pages
#
#  id                :integer          not null, primary key
#  wikipedia_page_id :integer          default(0), not null
#  category_title    :string(255)      default(""), not null
#  sortkey           :string(255)      default(""), not null
#  timestamp         :datetime
#  sortkey_prefix    :string(255)      default(""), not null
#  collation         :string(255)      default(""), not null
#  category_type     :integer          default("page"), not null
#
# Indexes
#
#  collation_ext                                                   (collation,category_title,category_type,wikipedia_page_id)
#  from_to                                                         (wikipedia_page_id,category_title) UNIQUE
#  index_wikipedia_category_pages_on_category_title_and_timestamp  (category_title,timestamp)
#  sortkey                                                         (category_title,category_type,sortkey,wikipedia_page_id)
#

class WikipediaCategoryPage < WikipediaRecord
  enum category_type: [:page, :subcat, :file]

  def self.sanitized_query(query_string)
    return standard_sanitized_query(query_string).
      gsub("UNIQUE KEY `cl_from`", "UNIQUE KEY `cl_from_and_to`").
      gsub("`cl_from`", "`wikipedia_page_id`").
      gsub("`cl_to`", "`category_title`").
      gsub("`cl_type`", "`category_type`").
      gsub("'page'", "0").
      gsub("'subcat'", "1").
      gsub("'file'", "2").
      gsub("`cl_", "`").
      gsub("`categorylinks`", "`" + table_name + "`")
  end
end
