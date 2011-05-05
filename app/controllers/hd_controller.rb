class HdController < ApplicationController
  before_filter :find_hard_drive_from_uuid

  def show
  end

  def release
    if request.delete?
      @hd.machines.each do |vm|
        vm.medium_attachments.each { |ma| ma.detach if ma.type == :hard_disk }
      end
      flash[:notice] = "#{@hd.filename} has been detached from all Virtual Machines."
      redirect_to hd_path
    end
  end

  def remove
    if @hd.machines.size > 0
      flash[:error] = "#{@hd.filename} cannot be deleted because it has virtual machines attached to it. Release them first."
      redirect_to hd_path
      return
    end

    if request.delete?
      @hd.destroy(true)
      flash[:notice] = "#{@hd.filename} has been deleted."
      redirect_to root_path
    end
  end
end
