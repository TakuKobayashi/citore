module ActiveAdminHelper
  def crawl_pull_down_script(models_hash)
    %Q{
      var model_columns = #{models_hash.to_json}
      $(document).ready(function(){
        var column_list_field = $("#target_class_column_field");
        $('#url_target_class').change(function(obj){
          var selectClassName = $(this).val();
          var list = model_columns[selectClassName];
          column_list_field.empty();
          if(!list){
            return;
          }
          for(var i = 0;i < list.length;++i){
            column_list_field.append(
              $('<li class="select input required" id="url_' + list[i] + '_input">').append(
                '<label for="' + list[i] + '" class="label">' + list[i] + '</label>',
                '<input id="url_' + list[i] + '" type="text" name="url[columns][' + list[i] + ']">'
              )
            );
          }
        });
      });
    }.html_safe
  end
end