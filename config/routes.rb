Rails.application.routes.draw do
  match '/auth/gds/callback', :to => 'authentications#callback', :as => 'gds_login_path'
end
