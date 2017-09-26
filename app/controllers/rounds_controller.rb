class RoundsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!, except: [:schedule]
  before_action :set_round, only: [:edit, :update]
  before_action :set_event, only: [:add, :remove]

  # GET /rounds
  def index
    @rounds = Round.all_ordered
  end

  # GET /rounds/1/edit
  def edit
  end

  # PATCH/PUT /rounds/1
  def update
    respond_to do |format|
      if @round.update(round_params)
        format.html { redirect_to edit_round_path(@round), flash: { success: 'Round was successfully updated.' }}
        format.json { render json: @round, status: :ok }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @round.errors, status: :unprocessable_entity }
        format.js { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  def add
    @event = Event.find(params[:event_id])
    prev_round_id = Round.where(event_id: @event.id).last&.r_id || 0
    round = Round.create!(event_id: @event.id, r_id: prev_round_id + 1)
    redirect_to groups_for_round_path(round.id)
  end

  def remove
    @event = Event.find(params[:event_id])
    last_round = Round.where(event_id: @event.id).last
    last_round&.destroy
    redirect_to groups_for_event_path(@event.id)
  end

  def schedule
    # For these, we actually want to display all attempts (ie: groups)
    fm_mbf = ["333fm", "333mbf"]
    @groups = Group.joins(:round).where('rounds.event_id': fm_mbf)
    # Hack for nations cup
    #@groups = @groups.to_a
    #@groups << Group.find(459)
    @rounds = Round.where.not(event_id: fm_mbf)
    @schedule_events = ScheduleEvent.all
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_round
      @round = Round.find(params[:id])
    end

    def set_event
      @event = Event.find(params[:event_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def round_params
      # event_id and r_id are immutable: they are set on round's creationg and
      # determined automatically
      permitted_params = [:start, :end]
      params.require(:round).permit(permitted_params)
    end
end
