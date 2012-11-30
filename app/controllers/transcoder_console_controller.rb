class TranscoderConsoleController < ApplicationController

  require "transcoder"

  TRANSCODER_HOST = '10.65.6.104'
  TRANSCODER_PORT = 10000

  def index
  end

  def perform
    transcoder = Transcoder.new(host: params[:host].empty? ? TRANSCODER_HOST : params[:host],
                                port: params[:port].empty? ? TRANSCODER_PORT : params[:port])

    @results = transcoder.mod_get_slots

    render :partial => "command_result"
  end

end
