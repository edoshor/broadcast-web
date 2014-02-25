class Admin::TranscodersController < TranscoderManagerController

  def index
    tm_get('transcoders') do |resp|
      @transcoders = resp.map { |atts| TMTranscoder.new(atts) }.sort_by! { |x| x.name }
    end
  end

  def show
    tm_get("transcoders/#{params[:id]}") do |resp|
      @transcoder = TMTranscoder.new(resp)
    end
    tm_get("transcoders/#{params[:id]}/slots") do |resp|
      @slots = resp.map { |atts| TMSlot.new(atts) }.sort
    end
    tm_get('schemes') do |resp|
      @schemes = resp.map { |atts| TMScheme.new(atts) }.sort_by! { |x| x.name }
    end
  end

  def new
    if params[:id]
      tm_get("transcoders/#{params[:id]}") do |resp|
        @transcoder = TMTranscoder.new(resp)
      end
    else
      @transcoder = TMTranscoder.new
    end
  end

  def create
    tm_post('transcoders', {params: params[:tm_transcoder].to_hash}) do
      redirect_to admin_transcoders_url, notice: 'Transcoder created successfully'
    end
  end

  def edit
    tm_get("transcoders/#{params[:id]}") do |resp|
      @transcoder = TMTranscoder.new(resp)
    end
  end

  def update
    tm_put("transcoders/#{params[:id]}", {params: params[:tm_transcoder].to_hash}) do
      redirect_to admin_transcoder_path(id: params[:id]), notice: 'Transcoder updated successfully'
    end
  end

  def destroy
    tm_delete("transcoders/#{ params[:id] }") do
      redirect_to admin_transcoders_url, notice: 'Transcoder deleted successfully'
    end
  end

  def action
    redirect_options = {action: :show, id: params[:id]}
    tm_get("transcoders/#{params[:id]}/#{params[:command]}",
           {fail_redirect: redirect_options}) do |resp|
      redirect_to(redirect_options, notice: resp)
    end
  end

  def create_slot
    atts = {
        slot_id: params[:slot_id],
        scheme_id: params[:scheme_id]
    }
    redirect_options = {action: :show, id: params[:id]}
    tm_post("transcoders/#{params[:id]}/slots",
            {params: atts, fail_redirect: redirect_options}) do
      redirect_to(redirect_options, notice: 'Slot created successfully')
    end
  end

  def delete_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_delete("transcoders/#{params[:id]}/slots/#{params[:slot_id]}",
              {fail_redirect: redirect_options}) do
      redirect_to(redirect_options, notice: 'Slot deleted successfully')
    end
  end

  def start_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_get("transcoders/#{params[:id]}/slots/#{params[:slot_id]}/start",
           {fail_redirect: redirect_options}) do
      redirect_to redirect_options
    end
  end

  def stop_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_get("transcoders/#{params[:id]}/slots/#{params[:slot_id]}/stop",
           {fail_redirect: redirect_options}) do
      redirect_to redirect_options
    end
  end

  def get_slots
    tm_get("transcoders/#{params[:id]}/slots",
           {fail_redirect: false, parse_body: false}) do |resp, alert|
      render_json_api_response resp, alert
    end
  end

  def slots_status
    tm_get("transcoders/#{params[:id]}/slots/status",
           {fail_redirect: false, parse_body: false}) do |resp, alert|
      render_json_api_response resp, alert
    end
  end

end
