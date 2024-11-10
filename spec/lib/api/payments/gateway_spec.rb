require 'webmock/rspec'

RSpec.describe Api::Payments::Gateway do

  let(:subscription) { double('Subscription', id: 'sub_12345') }
  let(:gateway) { described_class.new }
  let(:api_base_url) { Api::Payments::Constants::API_BASE_URL }
  let(:create_intent_endpoint) { Api::Payments::Constants::CREATE_INTENT_ENDPOINT }

  before do
    stub_request(:post, "#{api_base_url}#{create_intent_endpoint}")
      .to_return { |request| { body: { status: 'success' }.to_json, headers: { 'Content-Type' => 'application/json' } } }
  end

  describe '#create_payment_intent' do
    it 'sends a POST request to the payment gateway' do
      gateway.create_payment_intent(amount: 50.0, subscription_id: subscription.id)
      expect(WebMock).to have_requested(:post, "#{api_base_url}#{create_intent_endpoint}")
                           .with(body: { amount: 50.0, subscription_id: 'sub_12345' }.to_json)
    end

    it 'returns a Response object' do
      response = gateway.create_payment_intent(amount: 50.0, subscription_id: subscription.id)
      expect(response).to be_an_instance_of(Api::Payments::Response)
    end
  end
end