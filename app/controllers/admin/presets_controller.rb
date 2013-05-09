class Admin::PresetsController < ApplicationController

  def index
    tm_get('/presets') do |resp|
      @presets = JSON.parse(resp.body).map { |atts| TMPreset.new(atts) }
    end
  end

  def show
    tm_get("/presets/#{params[:id]}") do |resp|
      body = JSON.parse(resp.body)
      @preset = TMPreset.new(body)
      @tracks = body['tracks'].map { |track| TMTrack.new(track)}
    end
  end

  def new
    @preset = TMPreset.new
  end

  def create
    tm_post('/presets', params[:tm_preset].to_hash) do |resp|
      redirect_to admin_presets_url, notice: 'Preset created successfully'
    end
  end

  def destroy
    tm_delete("/presets/#{ params[:id] }") do |resp|
      redirect_to admin_presets_url, notice: 'Preset deleted successfully'
    end
  end

end
