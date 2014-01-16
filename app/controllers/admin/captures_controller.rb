class Admin::CapturesController < TranscoderManagerController

  def index
    tm_get('captures') do |resp|
      @captures = JSON.parse(resp.body)
      .map { |atts| TMCapture.new(atts) }
      .sort_by! { |x| x.name }
    end
  end

  def show
    tm_get("captures/#{params[:id]}") do |resp|
      @capture = TMCapture.new(JSON.parse(resp.body))
    end
  end

  def new
    @capture = TMCapture.new
  end

  def create
    tm_post('captures', params[:tm_capture].to_hash) do
      redirect_to admin_captures_url, notice: 'Capture created successfully'
    end
  end

  def edit
    tm_get("captures/#{params[:id]}") do |resp|
      @capture = TMCapture.new(JSON.parse(resp.body))
    end
  end

  def update
    tm_put("captures/#{params[:id]}", params[:tm_capture].to_hash) do
      redirect_to admin_capture_path(id: params[:id]), notice: 'Capture updated successfully'
    end
  end

  def destroy
    tm_delete("captures/#{ params[:id] }") do
      redirect_to admin_captures_url, notice: 'Capture deleted successfully'
    end
  end

end
