class Admin::EventsController < TranscoderManagerController

  def index
    tm_get('events') do |resp|
      @events = resp.map { |atts| TMEvent.new(atts) }.sort_by! { |x| x.name }
    end
  end

  def show
    tm_get("events/#{params[:id]}") do |resp|
      @event = TMEvent.new(resp)
    end
    tm_get("events/#{params[:id]}/slots") do |resp|
      @slots = resp.map { |atts| TMSlot.new(atts) }.sort
    end
    tm_get('transcoders') do |resp|
      @transcoders = resp.map { |atts| TMTranscoder.new(atts) }.sort_by! { |x| x.name }
    end
  end

  def new
    if params[:id]
      tm_get("events/#{params[:id]}") do |resp|
        @event = TMEvent.new(resp)
      end
    else
      @event = TMEvent.new
    end
  end

  def create
    tm_post('events', {params: params[:tm_event].to_hash}) do
      redirect_to admin_events_url, notice: 'Event created successfully'
    end
  end

  def edit
    tm_get("events/#{params[:id]}") do |resp|
      @event = TMEvent.new(resp)
    end
  end

  def update
    tm_put("events/#{params[:id]}", {params: params[:tm_event].to_hash}) do
      redirect_to admin_event_path(id: params[:id]), notice: 'Event updated successfully'
    end
  end

  def destroy
    tm_delete("events/#{ params[:id] }") do
      redirect_to admin_events_url, notice: 'Event deleted successfully'
    end
  end

  def action
    redirect_options = {action: :show, id: params[:id]}
    tm_get("events/#{params[:id]}/#{params[:command]}",
           {fail_redirect: redirect_options}) do
      redirect_to(redirect_options)
    end
  end

  def add_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_post("events/#{params[:id]}/slots",
            {params: {slot_id: params[:slot_id]}, fail_redirect: redirect_options}) do
      redirect_to(redirect_options, notice: 'Slot added successfully')
    end
  end

  def remove_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_delete("events/#{params[:id]}/slots/#{params[:slot_id]}",
              {fail_redirect: redirect_options}) do
      redirect_to(redirect_options, notice: 'Slot removed successfully')
    end
  end

  def status
    url = "events/#{params[:id]}/status"
    url += "?with_slots=#{params[:with_slots]}" if params[:with_slots]
    tm_get(url, {parse_body: false}) do |resp|
      @json = resp.body
      @statuses = JSON.parse resp.body
    end

    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @json }
    end
  end
end
