# frozen_string_literal: true

Rails.application.routes.draw do
  get "/not-restricted" => "example#not_restricted"
  get "/restricted" => "example#restricted"
  get "/this-requires-execute-permission" => "example#this_requires_execute_permission"
end
