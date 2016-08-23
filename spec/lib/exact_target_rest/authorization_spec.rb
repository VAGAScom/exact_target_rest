require 'spec_helper'

describe Authorization do

  let(:client_id) { "12345" }
  let(:client_secret) { "Y9axRxR9bcvSW2cc0IwoWeq7" }
  let(:expires_in) { 3600 }

  let(:access_token) { "75sf4WWbwfr6HYd5URpC6KBk" }

  subject do
    described_class
  end

  before do
    stub_requests
  end

  describe '#with_authorization' do
    it "returns a valid authorization" do
      subject.new(client_id, client_secret).with_authorization do |access_token|
        expect(access_token).to eq access_token
      end
    end

    it "returns Unauthorized" do
      expect {
        subject.new("invalid", client_secret).with_authorization
      }.to raise_error NotAuthorizedError
    end
  end

  describe '#authorize!' do
    it "returns a valid authorization" do
      auth = subject.new(client_id, client_secret).authorize!

      expect(auth.access_token).to eq access_token
      expect(auth.expires_in).not_to be_nil
    end

    it "returns Unauthorized" do
      expect {
        subject.new("invalid", client_secret).authorize!
      }.to raise_error NotAuthorizedError
    end
  end

  describe '#authorized?' do
    it "returns TRUE when authorization NOT Expired" do
      auth = subject.new(client_id, client_secret).authorize!

      expect(auth.authorized?).to be true
    end

    it "returns FALSE when authorization Expired" do
      auth = subject.new(client_id, client_secret).authorize!

      allow(Time).to receive(:now).and_return(auth.expires_in + 1)
      expect(auth.authorized?).to be false
    end
  end

  describe '#to_yaml' do
    it "serializes and deserializes Authorization" do
      auth = subject.new(client_id, client_secret).authorize!

      expect(YAML::load(auth.to_yaml)).to be_instance_of(ExactTargetRest::Authorization)
    end
  end

  private

  def stub_requests
    stub_request(:post, ExactTargetRest::AUTH_URL).
      with(
        :body => "{\"clientId\":\"#{client_id}\",\"clientSecret\":\"#{client_secret}\"}",
        :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'}
        ).
      to_return(
        headers: {"Content-Type"=> "application/json"},
        body: %({"accessToken": "#{access_token}", "expiresIn": 3600}),
        status: 200
      )

    stub_request(:any, ExactTargetRest::AUTH_URL).
      with(
        :body => "{\"clientId\":\"invalid\",\"clientSecret\":\"#{client_secret}\"}",
        :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'}
        ).
      to_return(
        headers: {"Content-Type"=> "application/json"},
        body: %({"message": "Unauthorized","errorcode": 1,"documentation": ""}),
        status: 401
      )
  end
end
