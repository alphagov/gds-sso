Rails.application.routes.draw do
  match '/auth/gds/callback', to: 'authentications#callback', as: :gds_sign_in
  match '/auth/gds/sign_out', to: 'authentications#sign_out', as: :gds_sign_out
  match '/auth/failure',  to: 'authentications#failure',  as: :auth_failure
  match '/authorisations/cant_signin', to: 'authorisations#cant_signin', as: :cant_signin
end
