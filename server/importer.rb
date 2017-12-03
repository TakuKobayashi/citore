files = Dir.glob(Rails.root.to_s + "/" + ARGV[0].to_s + "*")
files.each do |file|
  image_resource = Hackathon::Sunflower::ImageResource.new(category: :ferry, state: :fix)
  image_resource.upload!(File.open(file))
end