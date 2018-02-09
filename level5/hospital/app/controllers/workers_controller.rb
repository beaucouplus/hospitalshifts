class WorkersController < ApplicationController

  def new
    @worker = Worker.new
  end

  def create
    @worker = Worker.new(worker_params)
    if @worker.save
      respond_to do |format|
        format.html { redirect_to workers_path }
      end
    else
      respond_to do |format|
        flash[:worker_errors] = @worker.errors.messages
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  end

  def show
    @worker = Worker.find(params[:id])
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
      redirect_to @worker
    else
      render 'edit'
    end
  end

  private

  def worker_params
    params.require(:worker).permit(:first_name, :status)
  end

end
