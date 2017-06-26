class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!
  before_action :set_group, only: [:destroy, :edit, :update, :update_staff]

  SINGLE = %w(333bf 444bf 555bf 333fm 333mbf).freeze
  PREFIXES = %w([Su] [Mo] [Tu] [W] [T] [F] [Sa]).freeze

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

  def update_staff
    case params[:staff_action]
    when "teams-add-selected"
      return add_selected_staff_teams_to_group
    when "teams-remove-selected"
      return remove_selected_staff_teams_from_group
    when "registrations-remove-selected"
      return remove_selected_staff_people_from_group
    when "registrations-add-selected"
      return add_selected_staff_people_to_group
    when "registrations-update-roles"
      return update_roles_for_individual_staff
    else
      raise "Unrecognized action #{params[:registrations_action]}"
    end
  end

  def edit
    set_staff_teams!
  end

  def show
  end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to edit_group_path(@group), flash: { success: 'Group was successfully updated.' }}
        format.json { render json: @group, status: :ok }
      else
        format.html do
          set_staff_teams!
          flash[:danger] = 'Error when updating group'
          render :edit
        end
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
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
      redirect_to groups_url, alert: "Could not find the Round!"
    end
  end

  def schedule
    @groups = Group.includes(:staff_teams).all.order(:id)
    @schedule_events = ScheduleEvent.all
  end

  private
  def set_group
    @group = Group.includes({staff_teams_groups: [:staff_team], staff_registrations_groups: [:registration]}).find(params[:group_id])
  end

  def set_staff_teams!
    existing_team_ids = @group.staff_teams_groups.map(&:staff_team_id)
    prefix = PREFIXES[@group.start.strftime("%w").to_i]
    @team_available = StaffTeam.all.reject { |s| existing_team_ids.include?(s.id) }.select { |s| s.name.start_with?(prefix) }
    existing_ids = @group.staff_registrations_groups.map(&:registration_id)
    base_scope = @group.event_id == "333mbf" ? Registration.staff_available_mbf : Registration.staff_available
    @staff_available = base_scope.includes(:user).reject { |r| existing_ids.include?(r.id) }
  end

  def group_params
    # TODO: date and stuff!
    permitted_params = [:name, :start, :end, :color]
    # Make the round immutable if there are people in the group!
    if @group.nil? or @group.registrations.empty?
      permitted_params << :round_id
    end
    params.require(:group).permit(permitted_params)
  end

  def set_groups!
    @groups = Group.for_round(@round.id).includes(registration_groups: { registration: [:user, :staff_teams] }, staff_teams: [])
  end

  def set_groups_ungrouped!
    set_groups!
    registrations = if @round.r_id > 1
                      # Can't now who is qualified... Groups for non-first rounds are here for schedule!
                      []
                    elsif @event.id == "333fm" || @event.id == "333mbf"
                      Registration.includes(:registration_detail, :staff_teams).with_event(@event.id)
                    else
                      Registration.includes(:registration_detail, :staff_teams).with_event_without_group_for(@round, :user)
                    end
    registrations, registrations_staff = registrations.partition { |r| !r.details.staff }

    @ungrouped = Group.new(registration_groups: registrations.map { |r| r.registration_groups.build })
    @ungrouped_staff = Group.new(registration_groups: registrations_staff.map { |r| r.registration_groups.build })
  end

  def selected_teams_id
    params.require(:selected_teams).split(',').map { |r| r.split('-')[1].to_i }
  end

  def selected_registrations_ids
    params.require(:selected_registrations).split(',').map { |r| r.split('-')[1].to_i }
  end

  def add_selected_staff_teams_to_group
    team_ids = selected_teams_id
    existing_ids = @group.staff_teams_groups.map(&:staff_team_id)
    team_ids.reject { |id| existing_ids.include?(id) }.each do |id|
      @group.staff_teams_groups.build(staff_team: StaffTeam.find(id))
    end
    if @group.save
      flash[:success] = "Successfully added teams to group"
    else
      flash[:danger] = "Couldn't save group, maybe you try to add the same person twice?"
    end
    redirect_to edit_group_path(@group)
  end

  def add_selected_staff_people_to_group
    registration_ids = selected_registrations_ids
    existing_ids = @group.staff_registrations_groups.map(&:registration_id)
    registration_ids.reject { |id| existing_ids.include?(id) }.each do |id|
      @group.staff_registrations_groups.build(registration: Registration.find(id))
    end
    if @group.save
      flash[:success] = "Successfully added people to group"
    else
      flash[:danger] = "Couldn't save group, maybe you try to add the same person twice?"
    end
    redirect_to edit_group_path(@group)
  end

  def remove_selected_staff_people_from_group
    registration_ids = selected_registrations_ids
    @group.staff_registrations_groups.where(registration_id: registration_ids).map(&:destroy)
    redirect_to edit_group_path(@group)
  end

  def remove_selected_staff_teams_from_group
    team_ids = selected_teams_id
    @group.staff_teams_groups.where(staff_team_id: team_ids).map(&:destroy)
    redirect_to edit_group_path(@group)
  end

  def update_roles_for_individual_staff
    staff_registrations = params.require(:group).permit(staff_registrations_groups_attributes: [:id, :role])
    staff_registrations[:staff_registrations_groups_attributes]&.each do |_, data|
      details = StaffRegistrationsGroup.find(data[:id])
      details.update!(role: data[:role])
    end
    redirect_to edit_group_path(@group)
  end
end
