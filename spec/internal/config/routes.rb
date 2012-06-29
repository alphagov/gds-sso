Rails.application.routes.draw do
  root :to => 'example#index'
  match "/restricted" => 'example#restricted'
  match "/this_requires_signin_permission" => "example#this_requires_signin_permission"
end
