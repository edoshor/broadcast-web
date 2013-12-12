class Admin::PresetsController < TranscoderManagerController

  def index
    tm_get('/presets') do |resp|
      @presets = JSON.parse(resp.body)
      .map { |atts| TMPreset.new(atts) }
      .sort_by! { |x| x.name }
    end
  end

  def show
    tm_get("/presets/#{params[:id]}") do |resp|
      @json = resp.body
      body = JSON.parse(resp.body)
      @preset = TMPreset.new(body)
      @tracks = body['tracks'].map { |track| TMTrack.new(track) }
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
    args = params[:tm_preset]
    args[:tracks] = '[]' if args[:tracks].empty?
    atts = {
        name: args[:name],
        tracks: JSON.parse(args[:tracks])
    }

    tm_post('/presets', atts) do
      redirect_to admin_presets_url, notice: 'Preset created successfully'
    end
  end

  def destroy
    tm_delete("/presets/#{ params[:id] }") do
      redirect_to admin_presets_url, notice: 'Preset deleted successfully'
    end
  end

end
