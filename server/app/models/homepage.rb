module Homepage
  def self.table_name_prefix
    'homepage_'
  end

  def self.import_routine!
    Homepage::Tool.register_tools!
    Homepage::Article.import!
  end
end
