class Admin::SchemesController < TranscoderManagerController

  def index
    tm_get('schemes') do |resp|
      @schemes = resp.map { |atts| TMScheme.new(atts) }.sort_by! { |x| x.name }
    end
  end

  def show
    tm_get("schemes/#{params[:id]}") do |resp|
      @scheme = TMScheme.new(resp)
    end
  end

  def new
    @scheme = TMScheme.new
    tm_get('sources') do |resp|
      @sources = resp.map { |atts| TMSource.new(atts) }.sort_by! { |x| x.name }
    end
    tm_get('presets') do |resp|
      @presets = resp.map { |atts| TMPreset.new(atts) }.sort_by! { |x| x.name }
    end
    @first_preset = @presets.first
    tm_get("presets/#{@first_preset.id}") do |resp|
      @first_preset_tracks = resp['tracks'].map { |track| TMTrack.new(track) }
    end
  end

  def create
    args = params[:tm_scheme]
    atts = {
        name: args[:name],
        source1_id: args[:src1_id],
        source2_id: args[:src2_id],
        preset_id: args[:preset_id],
        audio_mappings: args[:audio_mappings]
    }
    tm_post('schemes', {params: atts}) do
      redirect_to admin_schemes_url, notice: 'Scheme created successfully'
    end
  end

  def edit
    tm_get("schemes/#{params[:id]}") do |resp|
      @scheme = TMScheme.new(resp)
    end
    tm_get('sources') do |resp|
      @sources = resp.map { |atts| TMSource.new(atts) }.sort_by! { |x| x.name }
    end
    tm_get('presets') do |resp|
      @presets = resp.map { |atts| TMPreset.new(atts) }.sort_by! { |x| x.name }
    end
    tm_get("presets/#{@scheme.preset_id}") do |resp|
      @current_preset_tracks = resp['tracks'].map { |track| TMTrack.new(track) }
    end
  end

  def update
    args = params[:tm_scheme]
    atts = {
        name: args[:name],
        source1_id: args[:src1_id],
        source2_id: args[:src2_id],
        preset_id: args[:preset_id],
        audio_mappings: args[:audio_mappings]
    }
    tm_put("schemes/#{params[:id]}", {params: atts}) do
      redirect_to admin_scheme_path(id: params[:id]), notice: 'Scheme updated successfully'
    end
  end

  def destroy
    tm_delete("schemes/#{ params[:id] }") do
      redirect_to admin_schemes_url, notice: 'Scheme deleted successfully'
    end
  end

end
