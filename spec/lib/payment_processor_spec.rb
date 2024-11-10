RSpec.describe PaymentProcessor do
  let(:payment_gateway) { instance_double('Api::Payments::Gateway') }
  let(:processor) { described_class.new(payment_gateway) }
  let(:subscription_id) { 'sub_12345' }
  let(:amount) { 50.0 }

  before do
    # Mock the RebillLogger to prevent actual logging and allow expectation setting
    allow(RebillLogger).to receive(:log)
  end

  describe '#attempt_payment' do
    let(:response_success) { Api::Payments::Response.new(status: 'success') }
    let(:response_failed) { Api::Payments::Response.new(status: 'failed') }
    let(:response_insufficient_funds) { Api::Payments::Response.new(status: 'insufficient_funds') }
    let(:response_unknown) { Api::Payments::Response.new(status: 'unknown_status') }

    context 'when payment is successful' do
      before do
        allow(payment_gateway).to receive(:create_payment_intent).and_return(response_success)
      end

      it 'returns a success response' do
        response = processor.attempt_payment(amount: amount, subscription_id: subscription_id)
        expect(response.success?).to be true
      end

      it 'logs the successful payment message' do
        expected_message = "Successfully charged $#{amount} for subscription #{subscription_id}."
        expect(RebillLogger).to receive(:log).with(expected_message)
        processor.attempt_payment(amount: amount, subscription_id: subscription_id)
      end
    end

    context 'when payment fails' do
      before do
        allow(payment_gateway).to receive(:create_payment_intent).and_return(response_failed)
      end

      it 'retries up to MAX_RETRIES times' do
        expect(payment_gateway).to receive(:create_payment_intent).exactly(PaymentProcessor::MAX_RETRIES).times
        processor.attempt_payment(amount: amount, subscription_id: subscription_id)
      end

      it 'logs the failure message after each attempt' do
        failure_message = "Payment failed for $#{amount} on subscription #{subscription_id}."
        expect(RebillLogger).to receive(:log).with(failure_message).exactly(PaymentProcessor::MAX_RETRIES).times
        processor.attempt_payment(amount: amount, subscription_id: subscription_id)
      end
    end

    context 'when payment is insufficient funds' do
      before do
        allow(payment_gateway).to receive(:create_payment_intent).and_return(response_insufficient_funds)
      end

      it 'does not retry and returns the insufficient funds response' do
        expect(payment_gateway).to receive(:create_payment_intent).once
        response = processor.attempt_payment(amount: amount, subscription_id: subscription_id)
        expect(response.insufficient_funds?).to be true
      end

      it 'logs the insufficient funds message' do
        expected_message = "Insufficient funds for $#{amount} on subscription #{subscription_id}."
        expect(RebillLogger).to receive(:log).with(expected_message)
        processor.attempt_payment(amount: amount, subscription_id: subscription_id)
      end
    end

    context 'when payment status is unknown' do
      before do
        allow(payment_gateway).to receive(:create_payment_intent).and_return(response_unknown)
      end

      it 'does not retry and returns the unknown status response' do
        expect(payment_gateway).to receive(:create_payment_intent).once
        response = processor.attempt_payment(amount: amount, subscription_id: subscription_id)
        expect(response.unknown?).to be true
      end

      it 'logs the unknown status message' do
        unknown_status_message = "Unknown status 'unknown_status' for $#{amount} on subscription #{subscription_id}."
        expect(RebillLogger).to receive(:log).with(unknown_status_message)
        processor.attempt_payment(amount: amount, subscription_id: subscription_id)
      end
    end
  end
end