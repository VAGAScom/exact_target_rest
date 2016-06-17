module ExactTargetRest
  class DataExtension
    # Execute operations over DataExtension
    #
    # @param authorization [Authorization]
    # @param external_key [String] The string that identifies the DataExtension
    # @param key_field [String] field used as primary key (if just one)
    # @param key_fields [Array<String>] fields used as composed primary key (if more than one)
    # @param snake_to_camel [Boolean] Attributes should be converted to CamelCase? (default true)
    def initialize(authorization, external_key, key_field: nil, key_fields: [key_field], snake_to_camel: true)
      @authorization = authorization
      @external_key = external_key
      @param_formatter = DataExtParams.new(*key_fields.compact, snake_to_camel: snake_to_camel)
    end

    # Upsert DataExtension rows (batch).
    #
    # Update or insert row based on primary keys
    #
    # @param data_extension_rows [Array<Hash<Symbol, Object>>, Hash<Symbol, Object>>]
    #   <code>{keys: {}, values: {}}</code>,"keys" are DataExtension primary keys and
    #   "values" are column values
    def upsert(data_extension_rows)
      @authorization.with_authorization do |access_token|
        resp = endpoint.post do |p|
          p.url(format(DATA_EXTENSION_PATH, URI.encode(@external_key)))
          p.headers['Authorization'] = "Bearer #{access_token}"
          p.body = @param_formatter.transform(data_extension_rows)
        end
        raise NotAuthorizedError if resp.status == 401
        resp
      end
    end

    protected

    def endpoint
      @endpoint ||= Faraday.new(url: DATA_EXTENSION_URL) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter FARADAY_ADAPTER
      end
    end
  end
end
