class Admin::SourcesController < TranscoderManagerController

  def index
    tm_get('sources') do |resp|
      @sources = resp.map { |atts| TMSource.new(atts) }.sort_by! { |x| x.name }
    end
  end

  def show
    tm_get("sources/#{params[:id]}") do |resp|
      @source = TMSource.new(resp)
    end
  end

  def new
    @source = TMSource.new
    tm_get('captures') do |resp|
      @captures = resp.map { |atts| TMCapture.new(atts) }.sort_by! { |x| x.name }
    end
  end

  def create
    tm_post('sources', {params: params[:tm_source].to_hash}) do
      redirect_to admin_sources_url, notice: 'Source created successfully'
    end
  end

  def edit
    tm_get("sources/#{params[:id]}") do |resp|
      @source = TMSource.new(resp)
    end
    tm_get('captures') do |resp|
      @captures = resp.map { |atts| TMCapture.new(atts) }.sort_by! { |x| x.name }
    end
  end

  def update
    tm_put("sources/#{params[:id]}", {params: params[:tm_source].to_hash}) do
      redirect_to admin_source_path(id: params[:id]), notice: 'Source updated successfully'
    end
  end

  def destroy
    tm_delete("sources/#{ params[:id] }") do
      redirect_to admin_sources_url, notice: 'Source deleted successfully'
    end
  end

end
