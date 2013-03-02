class Admin::TranscodersController < ApplicationController

  def index
    begin
      resp = api.get '/transcoders'
      @transcoders = JSON.parse resp.body
    rescue => error
      flash[:error] = error.message
      redirect_to root_url
    end
  end

  def show
    begin
      resp = api.get "/transcoders/#{params[:id]}"
      @transcoder = JSON.parse resp.body
      resp = api.get "/transcoders/#{params[:id]}/slots"
      @slots = JSON.parse resp.body
    rescue => error
      flash[:error] = error.message
      redirect_to root_url
    end
  end

  def status
    begin
      resp = api.get "/transcoders/#{params[:id]}/status"
      @transcoder = JSON.parse resp.body
    rescue => error
      flash[:error] = error.message
      redirect_to root_url
    end
  end

end
