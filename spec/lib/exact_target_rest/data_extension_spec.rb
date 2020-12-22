require 'spec_helper'

describe DataExtension do
  let(:auth_url) { "https://auth-url" }
  let(:rest_instance_url) { "https://instance-url" }
  let(:external_key) { "12345" }
  let(:access_token) { "Y9axRxR9bcvSW2cc0IwoWeq7" }
  let(:expires_in) { 3600 }

  subject do
    authorization = instance_double("ExactTargetRest::Authorization")
    allow(authorization).to receive(:with_authorization).and_yield(access_token)
    allow(authorization).to receive(:rest_instance_url).and_return(rest_instance_url)
    described_class.new(authorization,external_key)
  end

  before do
    stub_authentication
  end

  describe '#upsert' do
    it "does an upsert and return 200" do
      stub_successful_upsert

      response = subject.upsert({foo: 'bar'})
      expect(response.status).to eq 200
    end

    it "raises NotAuthorizedError when status code is 401" do
      stub_unauthorized_upsert

      expect {
        subject.upsert({foo: 'bar'})
      }.to raise_error(NotAuthorizedError)
    end

    it "raises StandardError if status code is 400" do
      stub_malformed_upsert

      expect {
        subject.upsert({foo: 'bar'})
      }.to raise_error(StandardError, /Unable to save rows/)
    end
  end

  private

  def stub_authentication
    stub_request(:any, "#{auth_url}#{AUTH_PATH}").
      to_return(
        headers: {"Content-Type"=> "application/json"},
        body: %({"access_token": "75sf4WWbwfr6HYd5URpC6KBk", "expires_in": 3600}),
        status: 200
      )
  end

  def upsert_body
    {
      :body => "[{\"keys\":{},\"values\":{\"Foo\":\"bar\"}}]",
      :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>"Bearer #{access_token}", 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.17.3'}
    }
  end

  def stub_successful_upsert
    stub_request(:post, data_extension_url).
      with(upsert_body).
      to_return(
        headers: {"Content-Type"=> "application/json"},
        body: "",
        status: 200
      )
  end

  def stub_unauthorized_upsert
    stub_request(:post, data_extension_url).
      with(upsert_body).
      to_return(
        headers: {"Content-Type"=> "application/json"},
        body: "",
        status: 401
      )
  end

  def stub_malformed_upsert
    stub_request(:post, data_extension_url).
      with(upsert_body).
      to_return(
        headers: {"Content-Type"=> "application/json"},
        body: "Unable to save rows",
        status: 400
      )
  end

  def data_extension_url
    "#{rest_instance_url}#{DATA_EXTENSION_PATH}" % external_key
  end
end
