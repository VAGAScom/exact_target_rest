module ExactTargetRest
  # Initiate user journey via ExactTarget API.
  #
  # You can create "Client ID" and "Client Secret" in ExactTarget
  # App Center (https://appcenter-auth.exacttargetapps.com).
  class InteractionEvent
    attr_reader :authorization

    def initialize(authorization)
      @authorization = authorization
      @params_formatter = InteractionEventParams.new :contact_key, :event_definition_key
    end

    def start_journey(params)
      @authorization.with_authorization do |access_token|
        resp = endpoint.post do |p|
          p.url(INTERACTION_EVENT_PATH)
          p.headers['Authorization'] = "Bearer #{access_token}"
          p.body = @params_formatter.transform(params)
        end
        raise NotAuthorizedError if resp.status == 401
        raise StandardError.new(resp.body) if resp.status != 200 and resp.status != 401
        resp
      end
    end

    def endpoint
      @endpoint ||= Faraday.new(url: authorization.rest_instance_url) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter FARADAY_ADAPTER
      end
    end
  end
end
