class TranscoderConsoleController < ApplicationController

  require "transcoder_api"

  def index
  end

  def perform
    api = TranscoderApi.new(
        host: params[:host].empty? ? GlobalConstants::TRANSCODER_HOST : params[:host],
        port: params[:port].empty? ? GlobalConstants::TRANSCODER_PORT : params[:port])

    @results = api.mod_get_slots

    render :partial => "command_result"
  end

end
