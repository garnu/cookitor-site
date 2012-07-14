Cookitor::Application.routes.draw do
  root :to => "pages#home"

  post "decode" => "rails_sessions#decode"
end
