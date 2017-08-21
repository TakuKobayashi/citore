class Tools::GraphicsController < Homepage::BaseController
  def canvas
  end

  def base64
    ime = ImageMetum.first
    render plain: ime.convert_to_base64
  end

  def threed
  end
end
