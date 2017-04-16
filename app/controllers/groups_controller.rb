class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!

  def show_for_event
    begin
      @event = Event.find(params[:event_id])
      @groups = EventGroup.for_event(@event.id).includes(:user).group_by(&:group)
      @ungrouped = Registration.registered_without_group_for(@event.id, :user)
    rescue ActiveRecord::RecordNotFound => e
      redirect_to groups_url, alert: "Could not find the event!"
    end
  end
end
