class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!

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
end
