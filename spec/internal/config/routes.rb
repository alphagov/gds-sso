Rails.application.routes.draw do
  root :to => 'example#index'
  get "/restricted" => 'example#restricted'
  get "/this_requires_signin_permission" => "example#this_requires_signin_permission"
end
