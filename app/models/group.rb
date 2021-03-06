class Group < ApplicationRecord
  #Colors are BLUE > YELLOW > RED > GREEN
  COLORS = Hash[
    #Five stage colors, blue is the front row, red the back row, +white the side venue
    "blue" => "#e02826",
    "orange" => "#ddda45",
    "green" => "#304a96",
    "yellow" => "#3d9c46",
    "red" => "#ff9307",
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

  validate :included_in_round
  def included_in_round
    return unless errors.blank?

    unless start >= round.start
      errors.add(:start, "should be after parent's start_time")
    end
    unless self[:end] <= round.end
      errors.add(:end, "should be before parent's end_time")
    end
    unless start <= self[:end]
      errors.add(:end, "should be after start")
    end
  end

  accepts_nested_attributes_for :registration_groups
  accepts_nested_attributes_for :staff_teams_groups
  accepts_nested_attributes_for :staff_registrations_groups

  scope :for_round, -> (id) { where(round_id: id) }
  scope :for_color, -> (color) { where(color: color) }

  def hex_color
    COLORS[self[:color]]
  end

  def activity_code
    code = "#{event_id}-r#{round.r_id}"
    if name =~ /Group/
      code += "-g#{name.sub(/.*( Group[ ]+(?<n>[0-9]*))/,'\k<n>')}"
    end
    if name =~ /Attempt/
      code += "-a#{name.sub(/.*( Attempt[ ]+(?<n>[0-9]*))/, '\k<n>')}"
    end
    code
  end

  def group_number
    if name =~ /Group/
      name.sub(/.*( Group[ ]+(?<n>[0-9]*))/,'\k<n>').to_i
    else
      1
    end
  end

  def short_name(with_round_id=false)
    event_name = Event.find(event_id).short_name
    if with_round_id && event_id != "magic"
      event_name += " R#{round.r_id}"
    end
    if name =~ /Group/
      event_name + name.sub(/.*( Group[ ]+(?<n>[0-9]*))/,' G\k<n>')
    elsif name =~ /Gruppo/
      event_name + name.sub(/.*(Gruppo[ ]+(?<n>[0-9]*))/,' G\k<n>')
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
    replacement_names = staff_registrations_groups.map(&:replacement_name).compact
    regular_competitor_names = registrations.map(&:name)
    regular_staff = staff_teams.map(&:registrations).flatten.reject { |r| replacement_names.include?(r.name) || regular_competitor_names.include?(r.name) }
    (regular_staff + staff_registrations).flatten.sort_by(&:name)
  end

  def to_wcif(timezone)
    {
      "id": self.id,
      "name": self.name,
      "activityCode": self.activity_code,
      "startTime": timezone.local_to_utc(self.start).iso8601,
      "endTime": timezone.local_to_utc(self[:end]).iso8601,
      "childActivities": [],
    }
  end

  def to_event(user, staff=false)
    {
      "id": self.id,
      "resourceIds": user.registration.staff_teams.map { |st| "#{st.id}-#{user.id}" },
      "staff_event": staff,
      "title": self.name,
      "start": self.start,
      "color": self.hex_color,
      "end": self[:end],
    }
  end

  def self.clear_for_round(round_id)
    Group.for_round(round_id).map do |g|
      # There is no :dependent destroy, we can just delete all!
      g.registration_groups.delete_all
    end
  end
end
