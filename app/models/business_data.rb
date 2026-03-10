class BusinessData < ApplicationRecord
  self.table_name = "business_data"
  belongs_to :business_idea
end
