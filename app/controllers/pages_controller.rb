class PagesController < ApplicationController
  def home
  	session[:hello] = 'world!'
  end

  def ping
    render text: "Pong!\n#{Time.now}"
  end
end
