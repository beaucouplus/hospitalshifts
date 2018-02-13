class ShiftsController < ApplicationController

  def create
    @shift = Shift.new(shift_params)
    if @shift.save
      respond_to do |format|
        format.html { redirect_to shifts_path }
        flash[:success] = "Planning updated successfully"
      end
    else
      respond_to do |format|
        flash[:shift_errors] = @shift.errors.messages
        format.html { redirect_to shifts_path }
      end
    end
  end

  def index
    @shift = Shift.new
    @shifts = Shift.order(:start_date)
  end

  private

  def shift_params
    params.require(:shift).permit(:start_date,:worker_id)
  end

end
