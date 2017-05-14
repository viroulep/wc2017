class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!, except: [:show_for_registration]
  before_action :redirect_unless_can_view!, only: [:show_for_registration]
  before_action :set_group, only: [:destroy, :edit, :update]

  SINGLE = %w(333bf 444bf 555bf 333fm 333mbf).freeze

  # TODO: move this to environment
  GROUPS_VISIBLE = false

  def autogenerate_group
    @round = Round.find(params[:round_id])
    unless @round.r_id == 1
      flash[:warning] = "Can't generate groups for non first round!"
      return redirect_to groups_for_round_path(@round.id)
    end
    Group.clear_for_round(@round.id)
    @event = Event.find(@round.event_id)
    @groups = Group.for_round(@round.id).includes(registration_groups: { registration: [:user] })
    sort_column = SINGLE.include?(@event.id) ? "single" : "average"

    @registrations = Registration.with_event(@event.id, [:user, :personal_bests, :registration_groups]).sort_by do |r|
      r.best_for(@event.id, sort_column)&.as_solve_time || SolveTime::SKIPPED
    end

    if @groups.empty? || @registrations.empty?
      flash[:warning] = "No groups or registrations to distribute the data"
      return redirect_to groups_for_round_path(@round.id)
    end
    @group_ids = @groups.map(&:id)

    # TODO: this is a bit messy, clean it
    # TODO: the actual distribution we want is: last first, then spread the
    # top solvers on groups with id = 1 % 5 (front and featured row)
    chunk_size = (@registrations.size / @groups.size).to_i
    index = 0
    group_id = 0
    @registrations.each do |r|
      @groups[group_id].registration_groups.build(registration: r)
      index += 1
      if index%chunk_size == 0
        index = 0
        group_id += 1
        if group_id == @groups.size
          group_id -= 1
        end
      end
    end

    @groups.each(&:save)

    flash[:success] = "Done"
    redirect_to groups_for_event_path(@event.id)
  end

  def create
    @repeat_start = params.require(:repeat_start).to_i
    @repeat_end = params.require(:repeat_end).to_i
    all_good = true

    if @repeat_end - @repeat_start <= 0
      @group = Group.new(group_params)
      all_good = @group.save
    else
      (@repeat_start..@repeat_end).each do |i|
        this_group_params = group_params
        this_group_params[:name] += " #{i}"
        @group = Group.new(this_group_params)
        unless @group.save
          all_good = false
          break
        end
      end
    end

    if all_good
      flash[:success] = "Group(s) successfully created!"
      redirect_to groups_for_round_path(@group.round_id)
    else
      render :index
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_for_round_path(@group.round_id)
  end

  def edit
  end

  def update
    if @group.update_attributes(group_params)
      flash[:success] = "Group successfully saved!"
      redirect_to edit_group_path(@group)
    else
      render :edit
    end
  end

  def show_for_registration
    # Shows groups for a registration id!
    @registration = Registration.find_by_id(params[:registration_id]) || Registration.find_by(user_id: current_user.id)
    @groups = @registration.registration_groups
  end

  def show_for_event
    @event = Event.find(params[:event_id])
    @round = Round.where(event_id: @event.id).order(r_id: :asc).first
    respond_to do |format|
      format.html { set_groups_ungrouped! if @round }
      format.json { set_groups! if @round }
    end
    @groups ||= []
    render :show_for_round
  end

  def show_for_round
    @round = Round.find(params[:round_id])
    @event = Event.find(@round.event_id)
    respond_to do |format|
      format.html { set_groups_ungrouped! }
      format.json { set_groups! }
    end
  end

  def update_for_round
    begin
      round = Round.find(params[:round_id])
      flash = {}
      changed = 0
      data =  params.require(:group)
                    .permit(registration_groups_attributes: [:id, :group_id, :registration_id])
      data[:registration_groups_attributes]&.reject { |index, eg| eg[:group_id].blank? }.each do |index, eg|
        new_group = Group.find(eg[:group_id])
        event_group = RegistrationGroup.find_by_id(eg[:id])
        unless event_group
          registration = Registration.find(eg[:registration_id])
          event_group = registration.registration_groups.build
        end
        event_group.group_id = new_group.id
        event_group.save!
        changed += 1 if event_group.previous_changes.any?
      end
      flash[:success] = if changed > 0
                          "Successfully modified #{changed} entries."
                        else
                          "No changes made."
                        end
      redirect_to :groups_for_round, flash: flash
    rescue ActiveRecord::RecordNotFound => e
      redirect_to groups_url, alert: "Could not find the Group!"
    end
  end

  private
  def set_group
    @group = Group.find(params[:id])
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

  def group_params
    # TODO: date and stuff!
    permitted_params = [:name, :start, :end]
    # Make the round immutable if there are people in the group!
    if @group.nil? or @group.registrations.empty?
      permitted_params << :round_id
    end
    params.require(:group).permit(permitted_params)
  end

  def set_groups!
    @groups = Group.for_round(@round.id).includes(registration_groups: { registration: [:user] })
  end

  def set_groups_ungrouped!
    set_groups!
    @ungrouped = if @round.r_id > 1
                   # Can't now who is qualified... Groups for non-first rounds are here for schedule!
                   Group.new(registration_groups: [])
                 elsif @event.id == "333fm" || @event.id == "333mbf"
                   Group.new(registration_groups: Registration.with_event(@event.id).map { |r| r.registration_groups.build })
                 else
                   Group.new(registration_groups: Registration.with_event_without_group_for(@round, :user).map { |r| r.registration_groups.build })
                 end
  end
end
