class Admin::PresetsController < ApplicationController

  def index
    tm_get('/presets') do |resp|
      @presets = JSON.parse(resp.body).map { |atts| TMPreset.new(atts) }
    end
  end

  def show
    tm_get("/presets/#{params[:id]}") do |resp|
      @json = resp.body
      body = JSON.parse(resp.body)
      @preset = TMPreset.new(body)
      @tracks = body['tracks'].map { |track| TMTrack.new(track)}
    end

    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @json }
    end
  end

  def new
    @preset = TMPreset.new
  end

  def create
    atts = {name: params[:tm_preset][:name],
      tracks: JSON.parse(params[:tm_preset][:tracks])}
    tm_post('/presets', atts) do |resp|
      redirect_to admin_presets_url, notice: 'Preset created successfully'
    end
  end

  def destroy
    tm_delete("/presets/#{ params[:id] }") do |resp|
      redirect_to admin_presets_url, notice: 'Preset deleted successfully'
    end
  end

end
