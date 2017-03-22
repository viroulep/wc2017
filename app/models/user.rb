# frozen_string_literal: true
class User < ApplicationRecord
  include WCAModel
  has_one :registration

  # List of fields we accept in the db
  @@obj_info = %w(id name email wca_id country_iso2 avatar_url avatar_thumb_url)
  # Possible extension
    #'gender',
    #'dob',
    #'delegate_status',
    #'teams',
end
