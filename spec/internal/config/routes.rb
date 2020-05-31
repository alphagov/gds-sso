# frozen_string_literal: true

Rails.application.routes.draw do
  # Add your own routes here, or remove this file if you don't have need for it.
  root :to => 'example#index'
  get "/restricted" => 'example#restricted'
  get "/this_requires_signin_permission" => "example#this_requires_signin_permission"
end
