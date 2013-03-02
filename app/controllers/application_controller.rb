class ApplicationController < ActionController::Base
  protect_from_forgery

  def api
    @api ||= Faraday.new(url: BroadcastWeb.config.tm_api_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end
