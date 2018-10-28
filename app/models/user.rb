# frozen_string_literal: true
class User < ApplicationRecord
  include WCAModel
  include ApplicationHelper

  MISSING_CLAIM = {
    "Hallvard Moberg" => "2015MOBE01",
    "Leo Noel " => "2017NOEL01",
    "Aidan Odom" => "2017ODOM01",
    "Alexis Godefroy" => "2017GODE01",
    "Xingyu Wu (吴惺宇)" => "2016WUXI02",
    "Bat-Erdene Sambuudolgor (Бат-эрдэнэ)" => "2016SAMB04",
    "Laban Björfors Dejfen" => "2017DEJF01",
    "Javier Álvarez Suárez" => "2017SUAR04",
    "Artus Huet" => "2017HUET01",
    "Ge Qu (曲歌)" => "2007GEQU01",
  }.freeze


  COMP_PER_PERSON = JSON.parse(File.read(Rails.root.to_s + "/config/comp_per_person.json")).freeze

  has_one :registration, inverse_of: :user

  has_many :personal_bests

  # List of fields we accept in the db
  @@obj_info = %w(id name email wca_id country_iso2 avatar_url avatar_thumb_url gender birthdate)
  # Possible extension
    #'delegate_status',
    #'teams',

  def transliterated_name
    I18n.transliterate(name)
  end

  def can_edit_guests?
    Registration::EDIT_GUESTS || can_manage_competition?
  end

  def best_for(event_id, type)
    @best_for ||= {}
    @best_for[event_id] ||= {}
    @best_for[event_id][type] ||= personal_bests.select { |pb| pb.event_id == event_id && pb.result_type == type }.first
  end

  def can_manage_competition?
    managed_competition ?  managed_competition.admin_ids.split(",").include?(id.to_s) : false
  end

  def can_edit_registration?(registration)
    !registration.nil? && (can_manage_competition? || id == registration.user_id)
  end

  def has_avatar?
    !avatar_thumb_url.blank?
  end

  def avatar
    avatar_thumb_url
  end

  def staff?
    registration&.details&.staff || can_manage_competition?
  end

  def self.process_json(json_user)
    # if such field exists, we are importing the WCIF,
    # else it's just a regular user login
    if json_user.include?("wcaUserId")
      json_user["id"] = json_user.delete("wcaUserId")
    end

    if json_user.include?("avatar")
      json_user["avatar_url"] = json_user["avatar"]["url"]
      json_user["avatar_thumb_url"] = json_user["avatar"]["thumbUrl"] || json_user["avatar"]["thumb_url"]
      json_user.delete("avatar")
    end
    %w(delegatesCompetition organizesCompetition registration personalBests).each do |k|
      json_user.delete(k)
    end
    if json_user.include?("birthdate")
      json_user["birthdate"] = json_user["birthdate"].to_date
    end
    json_user
  end

  def self.create_or_update(json_user)
    json_user = process_json(json_user)
    wca_create_or_update(json_user)
  end
end
