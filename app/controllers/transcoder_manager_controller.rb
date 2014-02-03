class TranscoderManagerController < ApplicationController

  def api
    @api ||= Faraday.new(url: BroadcastWeb.config.tm_api_url) do |faraday|
      faraday.request :url_encoded # form-encode POST params
      faraday.response :logger # log requests to STDOUT
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
  end

  def tm_get(path, options = {})
    opts = {fail_redirect: :back, parse_body: true }.merge(options)
    resp = wrap_error { api.get path }
    handle_response(resp, opts, &Proc.new)
  end

  def tm_post(path, options = {})
    opts = {params:{}, fail_redirect: :back}.merge(options)
    resp = wrap_error { api.post path, opts[:params] }
    handle_response(resp, opts, &Proc.new)
  end

  def tm_put(path, options = {})
    opts = {params:{}, fail_redirect: :back}.merge(options)
    resp = wrap_error { api.put path, opts[:params] }
    handle_response(resp, opts, &Proc.new)
  end

  def tm_delete(path, options = {})
    opts = {fail_redirect: :back, parse_body: true }.merge(options)
    resp = wrap_error { api.delete path }
    handle_response(resp, opts, &Proc.new)
  end

  def handle_response(resp, options = {}, &block)
    return unless resp.is_a? Faraday::Response

    if resp.success?
      block.call(options[:parse_body] ? JSON.parse(resp.body) : resp)
    else
      alert = extract_alert(resp)
      if options[:failure_url]
        redirect_to(options[:failure_url], alert: alert)
      else
        block.call(resp, alert)
      end
    end
  end

  def extract_alert(resp)
    if resp.headers['content-type'] =~ /.*application\/json.*/
      body = JSON.parse(resp.body)
      body['error'] || body
    else
      resp.body
    end
  end

  def wrap_error
    begin
      yield
    rescue => error
      redirect_to(root_url, alert: "Transcoder Manager error: #{ error.message }")
    end
  end

  def render_json_api_response(resp, alert)
    alert ? render(json: {errors: alert}, status: 422) : render(json: resp.body)
  end
end
