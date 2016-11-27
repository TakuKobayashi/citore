class ApkDownloaderController < BaseController
  def warakatsu
    send_file(Rails.root.to_s + "/apk_file/warakatsu_app.apk", :filename => "warakatsu.apk")
  end

  def citore
    send_file(Rails.root.to_s + "/apk_file/citore.apk", :filename => "citore.apk")
  end
end
