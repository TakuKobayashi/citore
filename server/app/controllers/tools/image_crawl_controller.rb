class Tools::ImageCrawlController < BaseController
  def index
  end

  def crawl
    if params[:html_file].present?
      doc = Nokogiri::HTML.parse(params[:html_file].read.to_s)
      images = ImageMetum.generate_objects_from_parsed_html(doc: doc, filter: params[:filter])
      ImageMetum.import!(images, on_duplicate_key_update: [:title])
    else
      url = params[:crawl_url]
      start_page = params[:start_page_num].to_i
      end_page = params[:end_page_num].to_i
      images = ImageMetum.crawl_images!(url: url, start_page: start_page, end_page: end_page, filter: params[:filter])
    end

    tempfile = Tempfile.new(Time.now.strftime("%Y%m%d_%H%M%S"))
    Zip::OutputStream.open(tempfile.path) do |stream|
      images.each do |image|
        next unless image.can_download?
        response = image.download_image
        next if (response.status >= 300 && response.status != 304) || !response.headers["Content-Type"].to_s.include?("image")
        stream.put_next_entry("image/#{image.save_filename}")
        stream.print(response.body)
      end
    end

    send_file tempfile.path, :type => 'application/zip',:disposition => 'attachment', :filename => "#{Time.now.strftime("%Y%m%d_%H%M%S")}.zip"
    tempfile.close
  end
end
