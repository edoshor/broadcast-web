class Admin::SourcesController < TranscoderManagerController

  def index
    tm_get('/sources') do |resp|
      @sources = JSON.parse(resp.body).map { |atts| TMSource.new(atts) }
    end
  end

  def show
    tm_get("/sources/#{params[:id]}") do |resp|
      @source = TMSource.new(JSON.parse(resp.body))
    end
  end

  def new
    @source = TMSource.new
    tm_get('/captures') do |resp|
      @captures = JSON.parse(resp.body).map { |atts| TMCapture.new(atts) }
    end
  end

  def create
    tm_post('/sources', params[:tm_source].to_hash) do
      redirect_to admin_sources_url, notice: 'Source created successfully'
    end
  end

  def destroy
    tm_delete("/sources/#{ params[:id] }") do
      redirect_to admin_sources_url, notice: 'Source deleted successfully'
    end
  end

end
