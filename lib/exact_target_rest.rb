require 'faraday'
require 'faraday_middleware'

module ExactTargetRest
  FARADAY_ADAPTER = :net_http
  AUTH_PATH = '/v2/token'
  TRIGGERED_SEND_PATH = '/messaging/v1/messageDefinitionSends/key:%s/send'
  DATA_EXTENSION_PATH = '/hub/v1/dataevents/key:%s/rowset'
  INTERACTION_EVENT_PATH = '/interaction/v1/events'
end

class NotAuthorizedError < StandardError
end

require 'exact_target_rest/support/string_extension'
require 'exact_target_rest/support/hash_extension'
require 'exact_target_rest/support/data_ext_params'
require 'exact_target_rest/support/interaction_event_params'
require 'exact_target_rest/version'
require 'exact_target_rest/authorization'
require 'exact_target_rest/triggered_send'
require 'exact_target_rest/data_extension'
require 'exact_target_rest/interaction_event'
