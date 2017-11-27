module HomepageHelper
  def generate_homepage_seo_header
    header_html = ""
    if controller_name == "image_crawl" && action_name == "index"
      header_html << %Q{
        <title>多くの画像ファイルを集めるためのツール置き場</title>
        <meta name="description" content="WebサイトやSNSからキーワードを入力するとその中の画像だけをまとめて集めてダウンロードすることができるツール置き場">
        <meta property="og:locale" content="ja_JP">
        <meta property="og:type" content="website">
        <meta property="og:title" content="多くの画像ファイルを集めるためのツール置き場">
        <meta property="og:description" content="WebサイトやSNSからキーワードを入力するとその中の画像だけをまとめて集めてダウンロードすることができるツール置き場">
        <meta property="og:url" content="#{tools_image_crawl_url}">
        <meta property="og:site_name" content="#{homepage_sitename}">
        <meta property="og:image" content="#{image_url("icon/image_crawler.png")}">
        <meta name="twitter:card" content="summary_large_image">
        <meta name="twitter:description" content="WebサイトやSNSからキーワードを入力するとその中の画像だけをまとめて集めてダウンロードすることができるツール置き場">
        <meta name="twitter:title" content="多くの画像ファイルを集めるためのツール置き場">
        <meta name="twitter:image" content="#{image_url("icon/image_crawler.png")}">
      }
    elsif controller_name == "webrtcs" && action_name == "index"
      header_html << %Q{
        <title>WebRTCを使ったビデオチャットとかやってみた系の遊び場</title>
        <meta name="description" content="WebRTCってなに？とか、WebRTCを実装したいというときに、とりあえずつないだり、どんなもの検証したりしたいときときのための場所">
        <meta property="og:locale" content="ja_JP">
        <meta property="og:type" content="website">
        <meta property="og:title" content="WebRTCを使ったビデオチャットとかやってみた系の遊び場">
        <meta property="og:description" content="WebRTCってなに？とか、WebRTCを実装したいというときに、とりあえずつないだり、どんなもの検証したりしたいときときのための場所">
        <meta property="og:url" content="#{tools_webrtcs_url}">
        <meta property="og:site_name" content="#{homepage_sitename}">
        <meta property="og:image" content="#{image_url("icon/webrtc.svg")}">
        <meta name="twitter:card" content="summary_large_image">
        <meta name="twitter:description" content="WebRTCってなに？とか、WebRTCを実装したいというときに、とりあえずつないだり、どんなもの検証したりしたいときときのための場所">
        <meta name="twitter:title" content="WebRTCを使ったビデオチャットとかやってみた系の遊び場">
        <meta name="twitter:image" content="#{image_url("icon/webrtc.svg")}">
      }
    elsif controller_name == "websockets" && action_name == "index"
      header_html << %Q{
        <title>WebSocketを使ったリアルタイム通信の遊び場</title>
        <meta name="description" content="WebSocketを使ったテストとか、実装するときにとりあえずつなぎたちとかそういうデモや実験を行うための場所">
        <meta property="og:locale" content="ja_JP">
        <meta property="og:type" content="website">
        <meta property="og:title" content="WebSocketを使ったリアルタイム通信の遊び場">
        <meta property="og:description" content="WebSocketを使ったテストとか、実装するときにとりあえずつなぎたちとかそういうデモや実験を行うための場所">
        <meta property="og:url" content="#{tools_websockets_url}">
        <meta property="og:site_name" content="#{homepage_sitename}">
        <meta property="og:image" content="#{image_url("icon/websocket.png")}">
        <meta name="twitter:card" content="summary_large_image">
        <meta name="twitter:description" content="WebSocketを使ったテストとか、実装するときにとりあえずつなぎたちとかそういうデモや実験を行うための場所">
        <meta name="twitter:title" content="WebSocketを使ったリアルタイム通信の遊び場">
        <meta name="twitter:image" content="#{image_url("icon/websocket.png")}">
      }
    elsif controller_name == "threed_objects" && action_name == "sample"
      header_html << %Q{
        <title>taku 3Dスキャンしてもらったデータのご紹介</title>
        <meta name="description" content="taku 3Dスキャンしてもらったデータの紹介と色々いじってもらうためのWeb3Dツールを取り揃えました">
        <meta property="og:locale" content="ja_JP">
        <meta property="og:type" content="website">
        <meta property="og:title" content="taku 3Dスキャンしてもらったデータのご紹介">
        <meta property="og:description" content="taku 3Dスキャンしてもらったデータの紹介と色々いじってもらうためのWeb3Dツールを取り揃えました">
        <meta property="og:url" content="#{sample_tools_threed_objects_url}">
        <meta property="og:site_name" content="#{homepage_sitename}">
        <meta property="og:image" content="#{image_url("icon/taku_model.png")}">
        <meta name="twitter:card" content="summary_large_image">
        <meta name="twitter:description" content="taku 3Dスキャンしてもらったデータの紹介と色々いじってもらうためのWeb3Dツールを取り揃えました">
        <meta name="twitter:title" content="taku 3Dスキャンしてもらったデータのご紹介">
        <meta name="twitter:image" content="#{image_url("icon/taku_model.png")}">
      }
    else
      header_html << %Q{
        <title>#{homepage_sitename}</title>
      }
    end
    return header_html.html_safe
  end
end
