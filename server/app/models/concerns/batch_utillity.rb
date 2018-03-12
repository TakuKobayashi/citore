module BatchUtility
  def self.execute_and_retry(sleep_second: nil)
    begin
      yield
    rescue RuntimeError => e
      logger = ActiveSupport::Logger.new("log/batch_error.log")
      console = ActiveSupport::Logger.new(STDOUT)
      logger.extend ActiveSupport::Logger.broadcast(console)
      message = "error: #{e.message}\n #{e.backtrace.join("\n")}\n"
      logger.info(message)
      puts message
      if sleep_second.present?
        sleep sleep_second
      end
      retry
    end
  end
end