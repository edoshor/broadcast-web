class Admin::SourcesController < ApplicationController

  def index
    begin
      resp = api.get '/sources'
      @sources = JSON.parse(resp.body).map { |atts| TMSource.new(atts) }
    rescue => error
      flash[:error] = error.message
      redirect_to root_url
    end
  end

  def show
    begin
      resp = api.get "/sources/#{params[:id]}"
      @source = TMSource.new(JSON.parse(resp.body))
    rescue => error
      flash[:error] = error.message
      redirect_to admin_sources_url
    end
  end

  def new
    @source = TMSource.new
  end

  def create
    begin
      resp = api.post '/sources', params[:tm_source].to_hash
      if resp.success?
        flash[:notice] = 'Source created successfully'
        redirect_to admin_sources_url
      else
        flash[:error] = resp.body
        redirect_to :back
      end
    rescue => error
      flash.now[:error] = error.message
      redirect_to :back
    end
  end

  def destroy
    begin
      resp = api.delete "/sources/#{ params[:id] }"
      if resp.success?
        flash[:notice] = 'Source deleted successfully'
      else
        flash[:error] = resp.body
      end
      redirect_to admin_sources_url
    rescue => error
      flash[:error] = error.message
      redirect_to root_url
    end
  end

end
