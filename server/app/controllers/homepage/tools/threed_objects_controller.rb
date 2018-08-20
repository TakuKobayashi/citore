class Homepage::Tools::ThreedObjectsController < Homepage::BaseController
  def index
  end

  def sample
  end

  def editor
  end

  def download
    counter = ExtraInfo.read_extra_info["threed_object_donwload_sum"].to_i
    ExtraInfo.update({"threed_object_donwload_sum" => counter + 1})
    redirect_to "https://s3-ap-northeast-1.amazonaws.com/taptappun/for_send/threed_models/taku_model.zip"
  end
end
