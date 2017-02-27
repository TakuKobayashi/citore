natto = ApplicationRecord.get_natto

arr = []
CSV.foreach(Rails.root.to_s + "") do |csv|
  label = "__label__" + csv[0]
end