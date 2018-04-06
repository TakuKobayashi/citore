class SidekiqWorkerBase
  include Sidekiq::Worker

  def sidekiq_alive?
    return true
  end
end