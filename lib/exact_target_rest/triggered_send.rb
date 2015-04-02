module ExactTargetRest
  class TriggeredSend
    # Execute TriggeredSends to one or several subscribers.
    #
    # @param authorization [Authorization]
    # @param external_key [String] The string that identifies the TriggeredSend
    # @param snake_to_camel [Boolean] Attributes should be converted to CamelCase? (default true)
    def initialize(authorization, external_key, snake_to_camel: true)
      @authorization = authorization
      @external_key = external_key
      @snake_to_camel = snake_to_camel
    end

    # TriggeredSend for just one subscriber.
    #
    # @param email_address [String] Email to send.
    # @param subscriber_key [String] SubscriberKey (it uses Email if not set).
    # @param data_extension_attributes [{Symbol => Object}] List of attributes (in snake_case)
    #   that will be used in TriggeredSend and will be saved in related DataExtension
    #   (in CamelCase).
    def send_one(email_address:, subscriber_key: email_address, ** data_extension_attributes)
      @authorization.with_authorization do |access_token|
        resp = endpoint.post do |p|
          p.url(format(TRIGGERED_SEND_PATH, URI.encode(@external_key)))
          p.headers['Authorization'] = "Bearer #{access_token}"
          p.body = {to: {
              address: email_address,
              subscriber_key: subscriber_key,
              contact_attributes: {
                  subscriber_attributes: prepare_attributes(data_extension_attributes)
              }
          }}
        end
        raise NotAuthorizedError if resp.status == 401
        resp
      end
    end

    protected

    def endpoint
      @endpoint ||= Faraday.new(url: TRIGGERED_SEND_URL) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter FARADAY_ADAPTER
      end
    end

    def prepare_attributes(attributes)
      @snake_to_camel ? attributes.snake_to_camel : attributes
    end
  end
end