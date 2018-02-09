class ShiftsController < ApplicationController
  def new
    @shift = Shift.new
    @statuses = ["medic","interne","interim"]
  end

  def create
    @shift = Shift.new(shift_params)
    if @shift.save
      respond_to do |format|
        format.html { redirect_to shifts_path }
      end
    else
      respond_to do |format|
        flash[:shift_errors] = @shift.errors.messages
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  end

  def show
    @shift = Shift.find(params[:id])
  end

  def index
    @shifts = Shift.all
  end

  def edit
    @shift = Shift.find(params[:id])
  end

  def update
    @shift = Shift.find(params[:id])
    if @shift.update_attributes(shift_params)
      flash[:success] = "Worker edited successfully"
      redirect_to @shift
    else
      render 'edit'
    end
  end

  private

  def shift_params
    params.require(:shift).permit(:start_date)
  end



end
