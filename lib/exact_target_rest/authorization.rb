module ExactTargetRest
  # An OAUTH2 REST authorization for ExactTarget API.
  #
  # You can create "Client ID" and "Client Secret" in ExactTarget
  # App Center (https://appcenter-auth.exacttargetapps.com).
  class Authorization
    attr_reader :auth_url
    attr_reader :access_token
    attr_reader :expires_in
    attr_reader :expires_at
    attr_reader :rest_instance_url

    # New authorization (it does not trigger REST yet).
    #
    # @param auth_url [String] Authentication URL
    # @param client_id [String] Client ID
    # @param client_secret [String] Client Secret
    def initialize(auth_url, client_id, client_secret)
      @auth_url = auth_url
      @client_id = client_id
      @client_secret = client_secret
    end

    # Guarantee the block to run authorized.
    #
    # If not yet authorized, it runs authorization.
    # If authorization is expired, it renews it.
    #
    # @yield [access_token] Block to be executed
    # @yieldparam access_token [String] Access token used to authorize a request
    def with_authorization
      authorize! unless authorized?
      yield @access_token
    end

    # Execute authorization, keeps an access token and returns the result
    def authorize!
      resp = endpoint.post do |p|
        p.url(AUTH_PATH)
        p.body = {client_id: @client_id,
                  client_secret: @client_secret,
                  grant_type: 'client_credentials'}
      end
      if resp.success?
        @access_token = resp.body['access_token']
        @expires_in = resp.body['expires_in']
        @expires_at = Time.now + @expires_in
        @rest_instance_url = resp.body['rest_instance_url']
        self
      else
        fail NotAuthorizedError
      end
    end

    # Already authorized and NOT expired?
    def authorized?
      @access_token && @expires_at > Time.now
    end

    protected

    def endpoint
      Faraday.new(url: auth_url) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter FARADAY_ADAPTER
      end
    end
  end
end
