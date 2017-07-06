class PrintingController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!

  def printable_schedules
    @registrations = Registration.includes([registration_detail: [], scramble_events: [], user: [], groups: [:round], staff_registrations_groups: { group: [:round] }, staff_teams_groups: { group: [:round] }])
    @side_event = ["333mbf", "444bf", "555bf"]
    length = 30
    offset = 0
    case params[:type]
    when "staff"
      @registrations = @registrations.staff_available.sort_by(&:name)
    else
      offset = params[:off]&.to_i || 0
      @registrations = @registrations.accepted.reject { |r| r.staff? }.sort_by(&:name)
      @registrations = @registrations.slice!(offset, length)
    end
  end

  def registrations
    inclusion = [ :registration_detail, :user, :guests ]
    @staff = Registration.staff_available.includes(inclusion).sort_by { |r| I18n.transliterate(r.name) }
    @competitors = (Registration.accepted.includes(inclusion) - @staff).sort_by { |r| I18n.transliterate(r.name) }
  end

  def rooms_side
    inclusion = {user: [:personal_bests]}
    @side_events = ["333mbf", "444bf", "555bf", "333fm"].map { |id| Event.find(id) }
    @registrations = {}

    @side_events.each do |e|
      @registrations[e] = Registration.with_event(e.id, inclusion)
      if e.id == "333mbf"
        @registrations[e].sort_by! { |r| r.best_for(e.id, "single") }
      else
        @registrations[e].sort_by! { |r| I18n.transliterate(r.name) }
      end
    end
  end
end
