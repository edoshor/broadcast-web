class Admin::TranscodersController < ApplicationController

  def index
    tm_get('/transcoders') do |resp|
      @transcoders = JSON.parse(resp.body).map { |atts| TMTranscoder.new(atts) }
    end
  end

  def show
    tm_get("/transcoders/#{params[:id]}") do |resp|
      @transcoder = TMTranscoder.new(JSON.parse(resp.body))
      tm_get("/transcoders/#{params[:id]}/slots") do |resp2|
        @slots = JSON.parse(resp2.body).map { |atts| TMSlot.new(atts) }
      end
    end
  end

  def new
    @transcoder = TMTranscoder.new
  end

  def create
    tm_post('/transcoders', params[:tm_transcoder].to_hash) do |resp|
      redirect_to admin_transcoders_url, notice: 'Transcoder created successfully'
    end
  end

  def destroy
    tm_delete("/transcoders/#{ params[:id] }") do |resp|
      redirect_to admin_transcoders_url, notice: 'Transcoder deleted successfully'
    end
  end

end
