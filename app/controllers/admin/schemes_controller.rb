class Admin::SchemesController < TranscoderManagerController

  def index
    tm_get('/schemes') do |resp|
      @schemes = JSON.parse(resp.body).map { |atts| TMScheme.new(atts) }
    end
  end

  def show
    tm_get("/schemes/#{params[:id]}") do |resp|
      body = JSON.parse(resp.body)
      @scheme = TMScheme.new(body)
    end
  end

  def new
    @scheme = TMScheme.new
    tm_get('/sources') do |resp|
      @sources = JSON.parse(resp.body).map { |atts| TMSource.new(atts) }
    end
    tm_get('/presets') do |resp|
      @presets = JSON.parse(resp.body).map { |atts| TMPreset.new(atts) }
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
    tm_post('/schemes', atts) do
      redirect_to admin_schemes_url, notice: 'Scheme created successfully'
    end
  end

  def destroy
    tm_delete("/schemes/#{ params[:id] }") do
      redirect_to admin_schemes_url, notice: 'Scheme deleted successfully'
    end
  end

end
