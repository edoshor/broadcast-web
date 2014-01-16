class Admin::EventsController < TranscoderManagerController

  def index
    tm_get('events') do |resp|
      @events = JSON.parse(resp.body)
      .map { |atts| TMEvent.new(atts) }
      .sort_by! { |x| x.name }
    end
  end

  def show
    tm_get("events/#{params[:id]}") do |resp|
      @event = TMEvent.new(JSON.parse(resp.body))
    end
    tm_get("events/#{params[:id]}/slots") do |resp|
      @slots = JSON.parse(resp.body).map { |atts| TMSlot.new(atts) }.sort
    end
    tm_get('transcoders') do |resp|
      @transcoders = JSON.parse(resp.body)
      .map { |atts| TMTranscoder.new(atts) }
      .sort_by! { |x| x.name }
    end
  end

  def new
    @event = TMEvent.new
  end

  def create
    tm_post('events', params[:tm_event].to_hash) do
      redirect_to admin_events_url, notice: 'Event created successfully'
    end
  end

  def edit
    tm_get("events/#{params[:id]}") do |resp|
      @event = TMEvent.new(JSON.parse(resp.body))
    end
  end

  def update
    tm_put("events/#{params[:id]}", params[:tm_event].to_hash) do
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
    tm_get("events/#{params[:id]}/#{params[:command]}", redirect_options) do
      redirect_to(redirect_options)
    end
  end

  def add_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_post("events/#{params[:id]}/slots", {slot_id: params[:slot_id]}, redirect_options) do
      redirect_to(redirect_options, notice: 'Slot added successfully')
    end
  end

  def remove_slot
    redirect_options = {action: :show, id: params[:id]}
    tm_delete("events/#{params[:id]}/slots/#{params[:slot_id]}", redirect_options) do
      redirect_to(redirect_options, notice: 'Slot removed successfully')
    end
  end

  def status
    url = "events/#{params[:id]}/status"
    url += "?with_slots=#{params[:with_slots]}" if params[:with_slots]
    tm_get(url) do |resp|
      @json = resp.body
      @statuses = JSON.parse resp.body
    end

    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @json }
    end
  end
end
