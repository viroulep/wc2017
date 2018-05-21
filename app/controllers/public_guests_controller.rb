class PublicGuestsController < ApplicationController
  before_action :set_public_guest, only: [:edit, :update, :destroy]
  before_action :redirect_unless_admin!, except: [:index, :new, :create]

  # GET /public_guests
  # GET /public_guests.json
  def index
    @public_guests = PublicGuest.all
    # tmp fix for Euro
    render :noop
  end

  # GET /public_guests/new
  def new
    @public_guest = PublicGuest.new
  end

  # GET /public_guests/1/edit
  def edit
  end

  # POST /public_guests
  # POST /public_guests.json
  def create
    @public_guest = PublicGuest.new(public_guest_params)

    if @public_guest.save
      flash[:success] = 'Public guest was successfully created.'
      redirect_to public_guests_url
    else
      render :new
    end
  end

  # PATCH/PUT /public_guests/1
  # PATCH/PUT /public_guests/1.json
  def update
    if @public_guest.update(public_guest_params)
      flash[:success] = 'Public guest was successfully updated.'
      redirect_to public_guests_url
    else
      render :edit
    end
  end

  # DELETE /public_guests/1
  # DELETE /public_guests/1.json
  def destroy
    @public_guest.destroy
    flash[:success] = 'Public guest was successfully destroyed.'
    redirect_to public_guests_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_public_guest
      @public_guest = PublicGuest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def public_guest_params
      params.require(:public_guest).permit(:fullname, :email)
    end
end
