class Group < ApplicationRecord

  COLORS = Hash[
    #Five stage colors, blue is the front row, red the back row, +white the side venue
    "blue" => "#2e81f8",
    "orange" => "#ff9307",
    "green" => "#46c81c",
    "yellow" => "#ffff1b",
    "red" => "#ff4439",
    "white" => "#dddddd",
  ].freeze

  has_many :registration_groups, inverse_of: :group, dependent: :delete_all
  has_many :registrations, through: :registration_groups
  has_many :users, through: :registrations

  has_many :staff_teams_groups, inverse_of: :group, dependent: :delete_all
  has_many :staff_registrations_groups, inverse_of: :group, dependent: :delete_all

  has_many :staff_teams, through: :staff_teams_groups
  has_many :staff_registrations, through: :staff_registrations_groups, source: :registration

  belongs_to :round

  delegate :event_id, to: :round

  validates_presence_of :name, allow_blank: false
  validates_presence_of :round_id, allow_blank: false
  validates_inclusion_of :color, in: COLORS.keys

  accepts_nested_attributes_for :registration_groups
  accepts_nested_attributes_for :staff_teams_groups
  accepts_nested_attributes_for :staff_registrations_groups

  scope :for_round, -> (id) { where(round_id: id) }

  def hex_color
    COLORS[self[:color]]
  end

  def short_name(with_round_id=false)
    event_name = Event.find(event_id).short_name
    if with_round_id && event_id != "magic"
      event_name += " R#{round.r_id}"
    end
    if name =~ /Group/
      event_name + name.sub(/.*( Group[ ]+(?<n>[0-9]*))/,' G\k<n>')
    elsif name =~ /Attempt/
      event_name + name.sub(/.*( Attempt (?<n>[0-9]*))/, ' #\k<n>')
    elsif name =~ /submission/
      event_name + " Submit cubes"
    else
      event_name + name
    end
  end

  def text_color
    "#000000"
  end

  def all_staff_people
    # For events like MBF and big blinds, staff teams contain competitors and staff !
    ((staff_registrations + staff_teams.map(&:registrations)).flatten - registrations).sort_by(&:name)
  end

  def self.clear_for_round(round_id)
    Group.for_round(round_id).map do |g|
      # There is no :dependent destroy, we can just delete all!
      g.registration_groups.delete_all
    end
  end
end
