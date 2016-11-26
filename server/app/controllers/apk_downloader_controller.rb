class ApkDownloaderController < BaseController
  def warakatsu
    send_file(Rails.root.to_s + "/apk_file/warakatsu_app.apk", :filename => "warakatsu.apk")
  end
end
