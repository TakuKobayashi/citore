class Tools::ImageCrawlController < Homepage::BaseController
  def index
  end

  def crawl
    if params[:html_file].present?
      doc = Nokogiri::HTML.parse(params[:html_file].read.to_s)
      images = Datapool::ImageMetum.generate_objects_from_parsed_html(doc: doc, filter: params[:filter])
      Datapool::ImageMetum.import!(images, on_duplicate_key_update: [:title])
    else
      url = params[:crawl_url]
      start_page = params[:start_page_num].to_i
      end_page = params[:end_page_num].to_i
      images = Datapool::ImageMetum.crawl_images!(url: url, start_page: start_page, end_page: end_page, filter: params[:filter])
    end

    tempfile = Tempfile.new(Time.now.strftime("%Y%m%d_%H%M%S"))
    Zip::OutputStream.open(tempfile.path) do |stream|
      images.each do |image|
        response = image.download_image_response
        next if (response.status >= 300 && response.status != 304) || !response.headers["Content-Type"].to_s.include?("image")
        stream.put_next_entry("image/#{image.save_filename}")
        stream.print(response.body)
      end
    end

    send_file tempfile.path, :type => 'application/zip',:disposition => 'attachment', :filename => "#{Time.now.strftime("%Y%m%d_%H%M%S")}.zip"
    tempfile.close
  end
end
