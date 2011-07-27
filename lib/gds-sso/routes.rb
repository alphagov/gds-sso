module ActionDispatch::Routing
  class Mapper
    # Allow you to add authentication request from the router:
    #
    #   authenticate(:user) do
    #     resources :post
    #   end
    #
    # Stolen from devise
    def authenticate(scope)
      constraint = lambda do |request|
        request.env["warden"].authenticate!(:scope => scope)
      end

      constraints(constraint) do
        yield
      end
    end
  end
end