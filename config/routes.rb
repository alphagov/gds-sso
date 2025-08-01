Rails.application.routes.draw do
  put  "/auth/gds/api/users/:uid",        to: "api/user#update"
  post "/auth/gds/api/users/:uid/reauth", to: "api/user#reauth"

  next if GDS::SSO::Config.api_only

  get "/auth/gds/callback",               to: "authentications#callback", as: :gds_sign_in
  get "/auth/gds/sign_out",               to: "authentications#sign_out", as: :gds_sign_out
  get "/auth/failure",                    to: "authentications#failure",  as: :auth_failure
end
