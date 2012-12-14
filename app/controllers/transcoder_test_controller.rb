class TranscoderTestController < ApplicationController
  require "transcoder_api"

  def index
  end

  def perform
    commands = params[:commands].split(/\r?\n/).map { |cmd| TranscoderCommand.create(cmd) }
    commands.delete nil
    @validations = commands.map{|command| [command, command.validate]}

    if @validations.all? {|validation| 'valid'.eql? validation[1]}
      transcoder = TranscoderManager.instance.get_transcoder('main')
      @results = commands.map {|command| [command, command.execute(transcoder)]}
      render :partial => 'batch_results'
    else
      render :partial => 'invalid_batch'
    end

  end
end
