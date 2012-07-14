class RailsSessionsController < ApplicationController
  def decode
    content = params[:content]
    @decoder = RailsSession::Decoder.new(content)
    if @decoder.valid?
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
