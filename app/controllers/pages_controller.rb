class PagesController < ApplicationController
  def home
  	session[:hello] = 'world!'
  end
end
