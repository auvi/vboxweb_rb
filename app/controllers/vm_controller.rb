class VmController < ApplicationController
  before_filter :find_virtual_machine_from_uuid
  before_filter :redirect_unless_vm_powered_off, :only => [:settings, :destroy]

  def show
  end

  def settings
    if request.put?
      begin
        settings_params.each { |attribute, value| @vm.send("#{attribute}=", value) }
        @vm.save
        flash[:notice] = "#{@vm.name} settings have been updated."
      rescue VirtualBox::Exceptions::CommandFailedException => e
        if e.to_s =~ /A session for the machine [\w\']* is currently open/
          flash[:error] = "Cannot update settings because the virtual machine is either running, paused, or someone is already editing it."
        else
          flash[:error] = e.to_s
        end
      end

      redirect_to vm_path
    end
  end

  def destroy
    if request.delete?
      @vm.destroy
      flash[:notice] = "#{@vm.name} has been deleted."
      redirect_to root_path
    end
  end

  def control
    case params[:command]
    when 'start'
      @vm.start(:vrdp) if @vm.powered_off? || @vm.saved? || @vm.aborted?
      flash[:notice] = "#{@vm.name} has been started, but give it a minute to fully boot."
    when 'shutdown'
      @vm.shutdown if @vm.running?
      flash[:notice] = "#{@vm.name} is being shutdown. Please wait a bit for it to complete and refresh the page."
    when 'poweroff'
      @vm.stop if @vm.running? || @vm.paused?
      flash[:notice] = "#{@vm.name} has been powered off. Any unsaved data will have been lost."
    when 'pause'
      @vm.pause if @vm.running?
      flash[:notice] = "#{@vm.name} has been paused."
    when 'resume'
      @vm.resume if @vm.paused?
      flash[:notice] = "#{@vm.name} has been resumed."
    when 'save'
      @vm.save_state if @vm.running? || @vm.paused?
      flash[:notice] = "#{@vm.name} has been saved. You may resume at any time by pressing 'Start'."
    when 'discard'
      @vm.discard_state if @vm.saved?
      flash[:notice] = "#{@vm.name} saved state has been discarded."
    else
      flash[:error] = "Unsupported Virtual Machine Operation '#{params[:command]}'"
    end

    redirect_to vm_path
  end

  private

  def settings_params
    params[:settings].each do |attribute, value|
      case value
      when /^\d/ then value = value.to_i
      when 'true' then value = true
      when 'false' then value = false
      end
      params[:settings][attribute] = value
    end

    params[:settings]
  end
end
