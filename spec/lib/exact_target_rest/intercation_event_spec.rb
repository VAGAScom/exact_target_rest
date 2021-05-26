require 'spec_helper'
require 'json/ext'

describe InteractionEvent do
  let(:auth_url) { "https://auth-url" }
  let(:rest_instance_url) { "https://instance-url" }
  let(:access_token) { "Y9axRxR9bcvSW2cc0IwoWeq7" }
  let(:expires_in) { 3600 }
  let(:start_journey_path) { "https://instance-url#{INTERACTION_EVENT_PATH}" }
  let(:event_instance_id) { '400609cc-f0b8-4234-8628-03367dde874c' }

  subject do
    authorization = instance_double("ExactTargetRest::Authorization")
    allow(authorization).to receive(:with_authorization).and_yield(access_token)
    allow(authorization).to receive(:rest_instance_url).and_return(rest_instance_url)
    described_class.new(authorization)
  end

  describe '#start_journey' do
    it "starts journey and returns 200" do
      stub_request(:post, start_journey_path)
        .with(self.request_data)
        .to_return(self.response_data)

      expect(subject.start_journey(event_definition_key: 'event_definition_key', contact_key: 'contact_key').body)
        .to eq({ 'eventInstanceId' => event_instance_id })
    end

    it "raises NotAuthorizedError when status code is 401" do
      stub_request(:post, start_journey_path)
        .with(self.request_data)
        .to_return(self.response_data(status: 401))

      expect {
        subject.start_journey(event_definition_key: 'event_definition_key', contact_key: 'contact_key')
      }
        .to raise_error(NotAuthorizedError)
    end

    describe "raises StandardError if status code is not successful (200..299):" do
      [400, 404, 500, 503, 504].each do |status_code|
        it "status code #{status_code}" do
          stub_request(:post, start_journey_path)
            .with(self.request_data)
            .to_return(self.response_data(status: status_code, body: 'Error message'))

          expect {
            subject.start_journey(event_definition_key: 'event_definition_key', contact_key: 'contact_key')
          }
            .to raise_error(StandardError, 'Error message')
        end
      end
    end

    describe "No error raised if status code is successful (200..299):" do
      (200..204).each do |status_code|
        it "status code #{status_code}" do
          stub_request(:post, start_journey_path)
            .with(self.request_data)
            .to_return(self.response_data)

          expect(subject.start_journey(event_definition_key: 'event_definition_key', contact_key: 'contact_key').body)
            .to eq({ 'eventInstanceId' => event_instance_id })
        end
      end
    end
  end

  def request_data(body: { EventDefinitionKey: 'event_definition_key', ContactKey: 'contact_key' })
    {
      :body => body.to_json,
      :headers => {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization' => "Bearer #{access_token}",
        'Content-Type' => 'application/json',
        'User-Agent' => %r'Faraday v.*'
      }
    }
  end

  def response_data(body: { eventInstanceId: event_instance_id }, status: 200)
    {
      headers: { "Content-Type" => "application/json" },
      body: body.to_json,
      status: status
    }
  end
end
