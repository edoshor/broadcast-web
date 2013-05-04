class Admin::TranscodersController < ApplicationController

  def index
    begin
      resp = api.get '/transcoders'
      @transcoders = JSON.parse(resp.body).map { |atts| TMTranscoder.new(atts) }
    rescue => error
      flash[:error] = error.message
      redirect_to root_url
    end
  end

  def show
    begin
      resp = api.get "/transcoders/#{params[:id]}"
      @transcoder = TMTranscoder.new(JSON.parse(resp.body))
      resp = api.get "/transcoders/#{params[:id]}/slots"
      @slots = JSON.parse(resp.body).map { |atts| TMSlot.new(atts) }
    rescue => error
      flash[:error] = error.message
      redirect_to admin_transcoders_url
    end
  end

  def new
    @transcoder = TMTranscoder.new
  end

  def create
    begin
      resp = api.post '/transcoders', params[:tm_transcoder].to_hash
      if resp.success?
        flash[:notice] = 'Transcoder created successfully'
        redirect_to admin_transcoders_url
      else
        flash[:error] = resp.body
        redirect_to :back
      end
    rescue => error
      flash.now[:error] = error.message
      redirect_to :back
    end
  end

  def destroy
    begin
      resp = api.delete "/transcoders/#{ params[:id] }"
      if resp.success?
        flash[:notice] = 'Transcoder deleted successfully'
      else
        flash[:error] = resp.body
      end
      redirect_to admin_transcoders_url
    rescue => error
      flash[:error] = error.message
      redirect_to root_url
    end
  end

end
