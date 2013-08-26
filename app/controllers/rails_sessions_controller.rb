class RailsSessionsController < ApplicationController
  def decode
    content = params[:content]
    key = params[:key_value] unless params[:key_value].blank?
    @decoder = RailsSession::Decoder.new(content, key)
    if @decoder.valid?
      session[:key] = key if key
    	render layout: false if hide_layout?
    else
    	render status: 422, text: @decoder.error unless @decoder.valid?
    end
  end

  private

  def hide_layout?
  	request.xhr? || params[:no_layout].present?
  end
end
