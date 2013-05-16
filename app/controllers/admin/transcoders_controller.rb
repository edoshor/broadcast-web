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
      tm_get('/schemes') do |resp|
        @schemes = JSON.parse(resp.body).map { |atts| TMScheme.new(atts) }
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

  def action
    resp = wrap_error { api.get "/transcoders/#{params[:id]}/#{params[:command]}" }
    if resp.success?
      redirect_to({ action: :show, id: params[:id] }, notice: resp.body)
    else
      redirect_to({ action: :show, id: params[:id] }, alert: resp.body)
    end
  end

  def create_slot
    atts = {
        slot_id: params[:slot_id],
        scheme_id: params[:scheme_id]
    }
    resp = wrap_error { api.post "/transcoders/#{params[:id]}/slots", atts }
    if resp.success?
      redirect_to({ action: :show, id: params[:id] }, notice: 'Slot created successfully')
    else
      redirect_to({ action: :show, id: params[:id] }, alert: resp.body)
    end
  end

  def delete_slot
    resp = wrap_error { api.delete "/transcoders/#{params[:id]}/slots/#{params[:slot_id]}" }
    if resp.success?
      redirect_to({ action: :show, id: params[:id] }, notice: 'Slot deleted successfully')
    else
      redirect_to({ action: :show, id: params[:id] }, alert: resp.body)
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
