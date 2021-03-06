# == Schema Information
#
# Table name: datapool_threed_model_compoments
#
#  id                :bigint(8)        not null, primary key
#  threed_model_id   :integer          not null
#  title             :string(255)      not null
#  original_filepath :string(255)
#  important         :boolean          default(FALSE), not null
#  data_category     :integer          default(0), not null
#  origin_src        :string(255)      not null
#  other_src         :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_threed_model_compoments_on_origin_src       (origin_src)
#  index_datapool_threed_model_compoments_on_threed_model_id  (threed_model_id)
#  index_datapool_threed_model_compoments_on_title            (title)
#

class Datapool::ThreedModelCompoment < ApplicationRecord
end
