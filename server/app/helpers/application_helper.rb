module ApplicationHelper
  def homepage_sitename
    return "TappunPage"
  end

  def show_header?
    not_show_headers = {
      "threed_objects" => ["sample"]
    }
    return not_show_headers[controller_name].blank? || !not_show_headers[controller_name].include?(action_name)
  end
end
