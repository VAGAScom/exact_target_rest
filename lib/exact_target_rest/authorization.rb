module ExactTargetRest
  # An OAUTH2 REST authorization for ExactTarget API.
  #
  # You can create "Client ID" and "Client Secret" in ExactTarget
  # App Center (https://appcenter-auth.exacttargetapps.com).
  class Authorization
    attr_reader :access_token

    # New authorization (it does not trigger REST yet).
    #
    # @param client_id [String] Client ID
    # @param client_secret [String] Client Secret
    def initialize(client_id, client_secret)
      @client_id, @client_secret = client_id, client_secret
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
      tries = 1
      begin
        yield @access_token
      rescue NotAuthorizedError
        authorize!
        tries -= 1
        retry if tries >= 0
      end

    end

    # Execute authorization and keeps an access token
    def authorize!
      resp = endpoint.post do |p|
        p.body = {clientId: @client_id,
                  clientSecret: @client_secret}
      end
      if resp.success?
        @access_token = resp.body['accessToken']
        @expires_in = Time.now + resp.body['expiresIn']
      else
        fail resp.body.inspect
      end
    end

    # Already authorized and NOT expired?
    def authorized?
      @access_token && @expires_in > Time.now
    end

    protected

    def endpoint
      @endpoint ||= Faraday.new(url: AUTH_URL) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter FARADAY_ADAPTER
      end
    end
  end
end
