module CacheStore
  CACHE = ActiveSupport::Cache::MemoryStore.new

  def self.memory_cached?
    CACHE.present?
  end

  def self.cache!
    self.cache_to_memory!
  end

  def self.cache_to_memory!
    CACHE.clear
    Citore::EroticWord.memory_cache!
    puts "[#{Time.now.strftime('%F %H:%M:%S')}] INFO data cached to memory"
  end
end