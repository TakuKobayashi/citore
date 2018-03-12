class CacheRecord < ApplicationRecord
  self.abstract_class = true

  after_save do
    update_cache!
  end

  before_destroy do
    destroy_cache!
  end

  def self.memory_cache!
    CacheStore::CACHE.write(self.table_name, self.all.index_by(&:id))
  end

  def self.find_by_used_cache(filter = {})
    records = CacheStore::CACHE.read(self.table_name)
    if records.blank?
      return self.find_by(filter)
    end
    if filter.key?(:id) || filter.key?("id")
      return records[filter["id"]] || records[filter[:id]]
    end
    return records.values.detect{|r| filter.all?{|k, v| r.send(k) == v } }
  end

  def self.where_used_cache(filter = {})
    records = CacheStore::CACHE.read(self.table_name)
    if records.blank?
      return self.where(filter).to_a
    end
    if filter.key?(:id) || filter.key?("id")
      value = records[filter["id"]] || records[filter[:id]]
      return [value].compact
    end
    return records.values.select{|r| filter.all?{|k, v| r.send(k) == v } }
  end

  def update_cache!
    records = CacheStore::CACHE.read(self.class.table_name)
    if records.present?
      records[self.id] = self
      CacheStore::CACHE.write(self.class.table_name, records)
    end
  end

  def destroy_cache!
    records = CacheStore::CACHE.read(self.class.table_name)
    if records.present?
      records.delete(self.id.to_s)
      CacheStore::CACHE.write(self.class.table_name, records)
    end
  end
end