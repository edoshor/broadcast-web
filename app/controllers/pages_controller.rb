class PagesController < TranscoderManagerController

  def home
    render action: 'home', layout: 'nomenu_layout'
  end

  def admin
    render action: 'home'
  end

  def advanced; end

  def monitoring
    tm_get('transcoders') do |resp|
      @transcoders = resp.map { |atts| TMTranscoder.new(atts) }.sort_by! { |x| x.name }
    end
  end
end
