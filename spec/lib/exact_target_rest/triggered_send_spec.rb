require 'spec_helper'

describe TriggeredSend do
  let(:auth_url) { "https://auth-url" }
  let(:rest_instance_url) { "https://instance-url" }
  let(:external_key) { "12345" }
  let(:access_token) { "Y9axRxR9bcvSW2cc0IwoWeq7" }
  let(:expires_in) { 3600 }

  subject do
    authorization = instance_double("ExactTargetRest::Authorization")
    allow(authorization).to receive(:with_authorization).and_yield(access_token)
    allow(authorization).to receive(:rest_instance_url).and_return(rest_instance_url)
    described_class.new(authorization, external_key)
  end

  before do
    stub_requests
  end

  describe '#send_one' do
    it "sends a simple TriggeredSend" do
      response = subject.send_one(email_address: "jake@oo.com")
      expect(response.body["requestId"]).to eq "simple-response-id"
    end

    it "sends a TriggeredSend with DataExtension" do
      response = subject.send_one(
        email_address: "jake@oo.com",
        city: "São Paulo",
        zip: "04063-040"
      )
      expect(response.body["requestId"]).to eq "data-extension-response-id"
    end
  end

  describe '#deliver' do
    it "sends a simple TriggeredSend" do
      response = subject.with_options(email_address: "jake@oo.com").deliver
      expect(response.body["requestId"]).to eq "simple-response-id"
    end

    it "sends a TriggeredSend with DataExtension" do
      response = subject.with_options(
        email_address: "jake@oo.com",
        subscriber_attributes: { City: "São Paulo", Zip: "04063-040" }
      ).deliver
      expect(response.body["requestId"]).to eq "data-extension-response-id"
    end

    it "sends a TriggeredSend with a DataExtension's key with spaces" do
      response = subject.with_options(
        email_address: "jake@oo.com",
        subscriber_attributes: { "City" => "São Paulo", "Profile ID" => "42" }
      ).deliver
      expect(response.body["requestId"]).to eq "uncommon-key-response-id"
    end

  end

  describe '#to_yaml' do
    it "serializes and deserializes TriggeredSend" do
      authorization = ExactTargetRest::Authorization.new(auth_url, "client_id", "client_secret").authorize!

      ts = ExactTargetRest::TriggeredSend.new(authorization, "external_key").
        with_options(
          email_address: "jake@oo.com",
          subscriber_attributes: { "City" => "São Paulo", "Profile ID" => "42" }
        )

      expect(YAML::load(ts.to_yaml)).to be_instance_of(ExactTargetRest::TriggeredSend)
    end
  end

  private

  def stub_requests
    stub_request(:any, "#{auth_url}#{AUTH_PATH}").
      to_return(
        headers: { "Content-Type" => "application/json" },
        body: %({"access_token": "75sf4WWbwfr6HYd5URpC6KBk", "expires_in": 3600}),
        status: 200
      )

    stub_request(:post, triggered_send_url).
      with(
        :body => "{\"From\":{\"Address\":\"\",\"Name\":\"\"},\"To\":{\"Address\":\"jake@oo.com\",\"SubscriberKey\":\"jake@oo.com\",\"ContactAttributes\":{\"SubscriberAttributes\":{\"City\":\"São Paulo\",\"Zip\":\"04063-040\"}}},\"OPTIONS\":{\"RequestType\":\"ASYNC\"}}",
        :headers => {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json',
          'User-Agent' => %r'Faraday v.*'
        }
      ).
      to_return(
        headers: { "Content-Type" => "application/json" },
        body: stub_response("data-extension-response-id"),
        status: 202
      )

    stub_request(:post, triggered_send_url).
      with(
        :body => "{\"From\":{\"Address\":\"\",\"Name\":\"\"},\"To\":{\"Address\":\"jake@oo.com\",\"SubscriberKey\":\"jake@oo.com\",\"ContactAttributes\":{\"SubscriberAttributes\":{\"City\":\"São Paulo\",\"Profile ID\":\"42\"}}},\"OPTIONS\":{\"RequestType\":\"ASYNC\"}}",
        :headers => {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json',
          'User-Agent' => %r'Faraday v.*'
        }
      ).
      to_return(
        headers: { "Content-Type" => "application/json" },
        body: stub_response("uncommon-key-response-id"),
        status: 202
      )

    stub_request(:post, triggered_send_url).
      with(
        :body => "{\"From\":{\"Address\":\"\",\"Name\":\"\"},\"To\":{\"Address\":\"jake@oo.com\",\"SubscriberKey\":\"jake@oo.com\",\"ContactAttributes\":{\"SubscriberAttributes\":{}}},\"OPTIONS\":{\"RequestType\":\"ASYNC\"}}",
        :headers => {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json',
          'User-Agent' => %r'Faraday v.*' }
      ).
      to_return(
        headers: { "Content-Type" => "application/json" },
        body: stub_response("simple-response-id"),
        status: 202
      )
  end

  def triggered_send_url
    "#{rest_instance_url}#{TRIGGERED_SEND_PATH}" % external_key
  end

  def stub_response(mockId)
    %({
      "requestId": "#{mockId}",
      "responses": [   {
        "recipientSendId": "#{mockId}",
        "hasErrors": false,
        "messages": ["Queued"]
      }]
    })
  end

end
