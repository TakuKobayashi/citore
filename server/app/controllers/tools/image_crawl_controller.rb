class Tools::ImageCrawlController < Homepage::BaseController
  def index
  end

  def twitter
  end

  def flickr
  end

  def url
  end

  def url_crawl
    url = params[:crawl_url]
    start_page = params[:start_page_num].to_i
    end_page = params[:end_page_num].to_i
    images = Datapool::WebSiteImageMetum.crawl_images!(url: url, start_page: start_page, end_page: end_page, filter: params[:filter])

    tempfile = Tempfile.new(Time.now.strftime("%Y%m%d_%H%M%S"))
    zippath = compress_to_zip(zip_filepath: tempfile.path, images: images)
    send_file zippath, :type => 'application/zip',:disposition => 'attachment', :filename => "#{Time.now.strftime("%Y%m%d_%H%M%S")}_#{params[:action]}.zip"
    tempfile.close
  end

  private
  def compress_to_zip(zip_filepath:, images: [])
    Zip::OutputStream.open(zip_filepath) do |stream|
      images.each do |image|
        response = image.download_image_response
        next if (response.status >= 300 && response.status != 304) || !response.headers["Content-Type"].to_s.include?("image")
        stream.put_next_entry("image/#{image.save_filename}")
        stream.print(response.body)
      end
    end
    return zip_filepath
  end
end