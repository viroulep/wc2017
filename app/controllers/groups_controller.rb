class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!, except: [:show]
  before_action :redirect_unless_can_view!, only: [:show]

  # TODO: move this to environment
  GROUPS_VISIBLE = false

  def show
    # Shows groups for a registration id!
    @registration = Registration.find_by_id(params[:registration_id]) || Registration.find_by(user_id: current_user.id)
    @groups = @registration.event_groups
  end

  def show_for_event
    begin
      @event = Event.find(params[:event_id])
      @groups = EventGroup.for_event(@event.id).includes(:user).group_by(&:group)
      @ungrouped = EventGroupCollection.new(Registration.registered_without_group_for(@event.id, :user).map do |r|
          r.event_groups.build(event_id: @event.id)
      end)
    rescue ActiveRecord::RecordNotFound => e
      redirect_to groups_url, alert: "Could not find the event!"
    end
  end

  def update_for_event
    begin
      @event = Event.find(params[:event_id])
      #TODO
      redirect_to :groups_for_event, flash: { success: "Successfully did nothing." }
    rescue ActiveRecord::RecordNotFound => e
      redirect_to groups_url, alert: "Could not find the event!"
    end
  end

  def redirect_unless_can_view!
    # NOTE: this has the side effect that if someone provides a wrong registration id,
    # they end up on their groups
    registration = Registration.find_by_id(params[:registration_id]) || Registration.find_by(user_id: current_user.id)
    unless current_user.can_edit_registration?(managed_competition, registration)
      flash[:danger] = "Cannot view groups for this registration"
      redirect_to root_url
      return
    end
    unless GROUPS_VISIBLE || current_user&.can_manage_competition?(managed_competition)
      redirect_to root_url, flash: { danger: 'Groups are not yet done.' }
    end
  end
end
