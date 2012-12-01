class TranscoderConsoleController < ApplicationController

  require "transcoder"

  def index
  end

  def perform
    transcoder = Transcoder.new(
        host: params[:host].empty? ? GlobalConstants::TRANSCODER_HOST : params[:host],
        port: params[:port].empty? ? GlobalConstants::TRANSCODER_PORT : params[:port])

    @results = transcoder.mod_get_slots

    render :partial => "command_result"
  end

end
