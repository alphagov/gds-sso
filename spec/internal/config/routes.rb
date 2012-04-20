Rails.application.routes.draw do
  root :to => 'example#index'
  match "/restricted" => 'example#restricted'
end
