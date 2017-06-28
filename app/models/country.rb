# frozen_string_literal: true

class Country < ApplicationRecord
  WCA_STATES_JSON_PATH = Rails.root.to_s + "/config/wca-states.json"

  WCA_STATES = JSON.parse(File.read(WCA_STATES_JSON_PATH)).freeze

  ALL_STATES = [
    WCA_STATES["states_lists"].map do |list|
      list["states"].map do |state|
        state_id = state["id"] || I18n.transliterate(state["name"]).tr("'", "_")
        { id: state_id, continentId: state["continent_id"],
          iso2: state["iso2"], name: state["name"] }
      end
    end,
  ].flatten.freeze

  def self.find_by_iso2(iso2)
    ALL_STATES.select { |c| c[:iso2] == iso2 }.first
  end
end
