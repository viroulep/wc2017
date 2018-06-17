class Competition < ApplicationRecord
  include WCAModel
  has_many :registrations

  validates :name, presence: true
  validates :admin_ids, presence: true, allow_blank: false

  @@obj_info = %w(id name admin_ids)

  def admins_array
    @admins_array ||= admin_ids.split(",").map(&:to_i)
  end

  def to_wcif
    {
      "formatVersion" => "1.0",
      "id" => id,
      "name" => name,
      "shortName" => name,
      "persons" => registrations.sort_by(&:transliterated_name).map(&:to_wcif),
      "schedule" => {
        # FIXME: hardcoded....
        "startDate": "2018-07-19",
        "numberOfDays": 4,
        "venues": [

        ]
      },
    }
  end
end
