# nochdir: true   - 相対パスでファイルの読み込みをするプラグインがあったときに
#                   不具合の出ないように
# noclose: false  - capistranoでデプロイしたときに制御端末を切り離すために
Process.daemon(true, false)

# killしやすいようにPIDを書き出す
require "fileutils"
pid = File.expand_path("/tmp/ruboty.pid", __FILE__)
FileUtils.mkdir_p(File.dirname(pid))
File.open(pid, "w") { |f| f.write Process.pid }