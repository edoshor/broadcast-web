class TranscoderManagerController < ApplicationController

  def api
    @api ||= Faraday.new(url: BroadcastWeb.config.tm_api_url) do |faraday|
      faraday.request :url_encoded # form-encode POST params
      faraday.response :logger # log requests to STDOUT
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
  end

  def tm_get(path, fail_redirect = :back)
    resp = wrap_error { api.get path }
    handle_response(resp, fail_redirect, &Proc.new)
  end

  def tm_post(path, params={}, fail_redirect = :back)
    resp = wrap_error { api.post path, params }
    handle_response(resp, fail_redirect, &Proc.new)
  end

  def tm_put(path, params={}, fail_redirect = :back)
    resp = wrap_error { api.put path, params }
    handle_response(resp, fail_redirect, &Proc.new)
  end

  def tm_delete(path, fail_redirect = :back)
    resp = wrap_error { api.delete path }
    handle_response(resp, fail_redirect, &Proc.new)
  end

  def handle_response(resp, failure_url = :back, &block)
    return unless resp.is_a? Faraday::Response

    if resp.success?
      block.call(resp)
    else
      alert = extract_alert(resp)
      if failure_url
        redirect_to(failure_url, alert: alert)
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
