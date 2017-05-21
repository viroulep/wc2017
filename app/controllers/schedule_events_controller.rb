class ScheduleEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!, except: [:schedule]
  before_action :set_schedule_event, only: [:show, :edit, :update, :destroy]

  # GET /schedule_events
  # GET /schedule_events.json
  def index
    @schedule_events = ScheduleEvent.all
  end

  # GET /schedule_events/new
  def new
    @schedule_event = ScheduleEvent.new
  end

  # GET /schedule_events/1/edit
  def edit
  end

  # POST /schedule_events
  # POST /schedule_events.json
  def create
    @schedule_event = ScheduleEvent.new(schedule_event_params)
    @schedule_event.save
  end

  # PATCH/PUT /schedule_events/1
  # PATCH/PUT /schedule_events/1.json
  def update
    @schedule_event.update(schedule_event_params)
  end

  # DELETE /schedule_events/1
  # DELETE /schedule_events/1.json
  def destroy
    @schedule_event.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule_event
      @schedule_event = ScheduleEvent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schedule_event_params
      params.require(:schedule_event).permit(:name, :start, :end)
    end
end
