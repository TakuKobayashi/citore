module WebNormalizer
  def self.merge_full_url(src:, org:)
    src_url = Addressable::URI.parse(src.to_s.gsub(/(\.\.\/|\.\/)+/,"/"))
    org_url = Addressable::URI.parse(org.to_s)
    pathes = src_url.path.to_s.split("/")
    # 空っぽもありうる
    if pathes.last.try(:include?, "#")
      pathes[pathes.size - 1] = pathes.last.gsub(/#.*/, "")
      src_url.path = pathes.join("/")
    end
    if (src_url.scheme.blank? || src_url.host.blank?)
      if src_url.path.to_s.first != "/"
        org_pathes = org_url.path.to_s.split("/")
        new_pathes = org_pathes[0..(org_pathes.size - 2)] + pathes
        src_url.path = new_pathes.join("/")
      end
    end
    if src_url.scheme.blank?
      src_url.scheme = org_url.scheme.to_s
    end
    if src_url.host.blank?
      src_url.host = org_url.host.to_s
    end
    return src_url
  end
end