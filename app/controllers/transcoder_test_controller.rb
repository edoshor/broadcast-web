class TranscoderTestController < ApplicationController
  require "transcoder"

  def index
  end

  def perform
    transcoder = Transcoder.new(
        host: GlobalConstants::TRANSCODER_HOST,
        port: GlobalConstants::TRANSCODER_PORT)

    commands = params[:commands].split(/\r?\n/).map { |cmd| TranscoderCommand.create(cmd) }

    @validations = commands.map{|command| [command, command.validate]}

    if @validations.all? {|validation| "valid".eql? validation[1]}
      @results = commands.map {|command| [command, command.execute(transcoder)]}
      render :partial => "batch_results"
    else
      render :partial => "invalid_batch"
    end

  end
end
