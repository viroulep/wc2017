class PrintingController < ApplicationController
  #before_action :authenticate_user!
  #before_action :redirect_unless_admin!

  layout 'print'

  def index
    render layout: "application"
  end

  def printable_schedules
    @registrations = Registration.includes([registration_detail: [], scramble_events: [], user: [], groups: [:round], staff_registrations_groups: { group: [:round] }, staff_teams_groups: { group: [:round] }])
    @side_event = ["333mbf", "444bf", "555bf"]
    length = 500
    offset = 0
    case params[:type]
    when "staff"
      @registrations = @registrations.staff_available.sort_by { |r| I18n.transliterate(r.name) }
    when "registration"
      @registrations = [Registration.find(params[:id])]
    else
      offset = params[:off]&.to_i || 0
      @registrations = @registrations.accepted.reject { |r| r.staff? }.sort_by { |r| I18n.transliterate(r.name) }
      @registrations = @registrations.slice!(offset, length)
    end
  end

  def printable_groups_schedule
    @groups = Group.includes(staff_teams: {staff_team_members: {registration: [:user]}}, round:[]).all.order(:id)
    @schedule_events = ScheduleEvent.all
  end

  def printable_rounds_schedule
    # For these, we actually want to display all attempts (ie: groups)
    fm_mbf = ["333fm", "333mbf"]
    @groups = Group.joins(:round).includes(:round).where('rounds.event_id': fm_mbf)
    @rounds = Round.where.not(event_id: fm_mbf)
    @schedule_events = ScheduleEvent.all
  end

  def printable_groups
    @groups = Group.includes(round: [], staff_teams: { registrations: [:user, :registration_detail, :scramble_events] }, registrations: [:user, :registration_detail, :scramble_events], staff_registrations: [:user, :registration_detail,:scramble_events]).all.order(:start).reject { |g| ["magic"].include?(g.event_id) }
  end

  def printable_groups_only
    @groups = Group.includes(round: []).all.order(:start)
  end

  def printable_teams
    @teams = StaffTeam.all.includes(registrations: [], users: [], staff_team_members: { registration: [:user]}).order(:name)
    @teams_array = {}
    @teams.each do |t|
      if t.name =~ /\[T/
        @teams_array["T"] ||= []
        @teams_array["T"] << t
      elsif t.name =~ /\[F/
        @teams_array["F"] ||= []
        @teams_array["F"] << t
      elsif t.name =~ /\[Sa/
        @teams_array["Sa"] ||= []
        @teams_array["Sa"] << t
      elsif t.name =~ /\[Su/
        @teams_array["Su"] ||= []
        @teams_array["Su"] << t
      else
        @teams_array["O"] ||= []
        @teams_array["O"] << t
      end
    end
  end

  def rooms_side
    inclusion = {user: [:personal_bests]}
    @side_events = ["333mbf", "444bf", "555bf", "333fm"].map { |id| Event.find(id) }
    @registrations = {}

    @side_events.each do |e|
      @registrations[e] = Registration.with_event(e.id, inclusion)
      @registrations[e].sort_by! { |r| r.best_for(e.id, "single")&.as_solve_time || SolveTime::DNF }
    end
  end
end
