class Admin::TranscodersController < ApplicationController

  def index
    tm_get('/transcoders') do |resp|
      @transcoders = JSON.parse(resp.body).map { |atts| TMTranscoder.new(atts) }
    end
  end

  def show
    tm_get("/transcoders/#{params[:id]}") do |resp|
      @transcoder = TMTranscoder.new(JSON.parse(resp.body))
      tm_get("/transcoders/#{params[:id]}/slots") do |resp|
        @slots = JSON.parse(resp.body).map { |atts| TMSlot.new(atts) }.sort
      end
      tm_get('/schemes') do |resp|
        @schemes = JSON.parse(resp.body).map { |atts| TMScheme.new(atts) }
      end
    end
  end

  def new
    @transcoder = TMTranscoder.new
  end

  def create
    tm_post('/transcoders', params[:tm_transcoder].to_hash) do
      redirect_to admin_transcoders_url, notice: 'Transcoder created successfully'
    end
  end

  def destroy
    tm_delete("/transcoders/#{ params[:id] }") do
      redirect_to admin_transcoders_url, notice: 'Transcoder deleted successfully'
    end
  end

  def action
    redirect_options = {action: :show, id: params[:id]}
    tm_get("/transcoders/#{params[:id]}/#{params[:command]}", redirect_options) do |resp|
      redirect_to(redirect_options, notice: resp.body)
    end
  end

  def create_slot
    atts = {
        slot_id: params[:slot_id],
        scheme_id: params[:scheme_id]
    }
    redirect_options = {action: :show, id: params[:id]}
    tm_post("/transcoders/#{params[:id]}/slots", atts, redirect_options) do
      redirect_to(redirect_options, notice: 'Slot created successfully')
    end
  end

  def delete_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_delete("/transcoders/#{params[:id]}/slots/#{params[:slot_id]}", redirect_options) do
      redirect_to(redirect_options, notice: 'Slot deleted successfully')
    end
  end

  def start_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_get("/transcoders/#{params[:id]}/slots/#{params[:slot_id]}/start", redirect_options) do
      redirect_to redirect_options
    end
  end

  def stop_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_get("/transcoders/#{params[:id]}/slots/#{params[:slot_id]}/stop", redirect_options) do
      redirect_to redirect_options
    end
  end

  def slots_status
    tm_get("/transcoders/#{params[:id]}/slots/status") do |resp|
      @json = resp.body
      @statuses = JSON.parse resp.body
    end

    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @json }
    end
  end

end
