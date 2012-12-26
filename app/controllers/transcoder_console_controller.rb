class TranscoderConsoleController < ApplicationController

  require "transcoder_api"
  require 'stub_transcoder_api'

  def index
  end

  def perform
    @results = get_transcoder().instance_eval params[:command]
    render :partial => "command_result"
  end

  private

  def get_transcoder
    if params[:host].blank?
      api = TranscoderManager.instance.master.api
    else
      port = params[:port].blank? ? 10000 : Integer(params[:port])
      api = TranscoderApi.new(host: params[:host], port: port)
    end

    api
    #StubTranscoderApi.new(host: 'host', port: 'port')
  end

end
