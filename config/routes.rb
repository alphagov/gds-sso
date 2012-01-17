Rails.application.routes.draw do
  match '/auth/gds/callback', to: 'authentications#callback', as: :gds_sign_in
  match '/auth/gds/sign_out', to: 'authentications#sign_out', as: :gds_sign_out
end
