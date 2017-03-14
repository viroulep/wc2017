# frozen_string_literal: true
class User < ApplicationRecord
  # List of fields we accept in the db
  USER_INFO = [
    'id',
    'name',
    'email',
    'wca_id',
    #'gender',
    'country_iso2',
    #'delegate_status',
    #'teams',
    'avatar_url',
    'avatar_thumb_url',
  ];

  def self.create_or_update(wca_user)
    db_record = self.find_by(uid: wca_user[:id])
    updated_info = wca_user.select { |key,_| USER_INFO.include?(key) }

    if db_record
      db_record.update(updated_info)
    else
      db_record = self.create!(updated_info)
    end

    db_record
  end

  def self.create_with_omniauth(me)
    #create! do |user|
      #user.provider = auth['provider']
      #user.uid = auth['uid']
      #if auth['info']
         #user.name = auth['info']['name'] || ""
      #end
    #end
  end

end
