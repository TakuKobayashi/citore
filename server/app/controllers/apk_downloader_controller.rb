class ApkDownloaderController < BaseController
  def warakatsu
    send_file("apk_file/warakatsu_app.apk", :filename => "warakatsu.apk")
  end
end
