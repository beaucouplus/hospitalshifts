class WorkersController < ApplicationController

  def create
    @worker = Worker.new(worker_params)
    @worker[:first_name].downcase
    if @worker.save
      respond_to do |format|
        flash[:success] = "Worker #{@worker.first_name} successfully created"
        format.html { redirect_to workers_path }
      end
    else
      respond_to do |format|
        flash[:worker_errors] = @worker.errors.messages
        format.html { redirect_to workers_path }
      end
    end
  end


  def index
    @worker = Worker.new
    @workers = Worker.all
  end

  def edit
    @worker = Worker.find(params[:id])
  end

  def update
    @worker = Worker.find(params[:id])
    if @worker.update_attributes(worker_params)
      flash[:success] = "Worker edited successfully"
      redirect_to edit_worker_path(params[:id])
    else
      flash[:worker_errors] = @worker.errors.messages
      render 'edit'
    end
  end

  private

  def worker_params
    params.require(:worker).permit(:first_name, :status)
  end

end
