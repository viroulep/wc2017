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
      flash = {}
      ignored = 0
      changed = 0
      event = Event.find(params[:event_id])
      # Note: event id is defined by the current event
      data =  params.require(:event_group_collection)
                    .permit(event_groups_attributes: [:id, :group, :registration_id])
      data[:event_groups_attributes]&.reject {|index, eg| eg[:group].blank? }.each do |index, eg|
        new_group = eg[:group].to_i
        event_group = EventGroup.find_by_id(eg[:id])
        unless event_group
          registration = Registration.find_by_id(eg[:registration_id])
          event_group = registration&.event_groups.build
        end
        if event_group && new_group > 0
          event_group.group = new_group
          event_group.event_id = event.id
          event_group.save!
          changed += 1 if event_group.previous_changes.any?
        else
          ignored += 1
        end
      end
      if ignored > 0
        flash[:warning] = "Ignored #{ignored} entries that couldn't be found in the db."
      end
      flash[:success] = if changed > 0
                          "Successfully modified #{changed} entries."
                        else
                          "No changes made."
                        end
      redirect_to :groups_for_event, flash: flash
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
    unless (GROUPS_VISIBLE && registration.accepted?) || current_user&.can_manage_competition?(managed_competition)
      flash[:danger] = "Groups are not yet done, or you don't have groups."
      redirect_to root_url
    end
  end
end
