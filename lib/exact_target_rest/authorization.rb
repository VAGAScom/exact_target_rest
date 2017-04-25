module ExactTargetRest
  # An OAUTH2 REST authorization for ExactTarget API.
  #
  # You can create "Client ID" and "Client Secret" in ExactTarget
  # App Center (https://appcenter-auth.exacttargetapps.com).
  class Authorization
    attr_reader :access_token
    attr_reader :expires_in
    attr_reader :expires_at

    # New authorization (it does not trigger REST yet).
    #
    # @param client_id [String] Client ID
    # @param client_secret [String] Client Secret
    def initialize(client_id, client_secret)
      @client_id, @client_secret = client_id, client_secret
    end

    # Customize the Faraday connection by passing in a block
    #
    def setup_connection(&block)
      @endpoint = endpoint(&block)
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
        p.body = {clientId: @client_id,
                  clientSecret: @client_secret}
      end
      if resp.success?
        @access_token = resp.body['accessToken']
        @expires_in = resp.body['expiresIn']
        @expires_at = Time.now + @expires_in
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

    def endpoint(&block)
      @endpoint || Faraday.new(url: AUTH_URL) do |f|
                     f.request :json
                     f.response :json, content_type: /\bjson$/
                     if block_given?
                       block.call(f)
                     else
                       f.adapter FARADAY_ADAPTER
                     end
                   end
    end
  end
end
