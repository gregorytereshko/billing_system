RSpec.describe BillingService do
  let(:payment_processor) { instance_double('PaymentProcessor') }
  let(:payment_scheduler) { class_double('PaymentScheduler') }
  let(:billing_service) { described_class.new(payment_processor: payment_processor, payment_scheduler: payment_scheduler) }
  let(:subscription) { Subscription.new(id: 'sub_12345', price: 100.0, subscription_type: :monthly, start_date: Date.today) }

  before do
    allow(RebillLogger).to receive(:log)
    allow(payment_scheduler).to receive(:schedule)
  end

  describe '#bill' do
    context 'when subscription is already fully paid' do
      it 'does not attempt to bill and logs paid status' do
        subscription.add_payment(100.0)
        expect(RebillLogger).to receive(:log).with("Subscription #{subscription.id} is already fully paid.")
        expect(payment_processor).not_to receive(:attempt_payment)
        billing_service.bill(subscription)
      end
    end

    context 'when subscription is not fully paid' do
      before do
        allow(payment_processor).to receive(:attempt_payment)
      end

      it 'does not schedule rebilling if subscription becomes fully paid' do
        response = Api::Payments::Response.new(status: 'success')
        allow(payment_processor).to receive(:attempt_payment).and_return(response)

        billing_service.bill(subscription)

        expect(subscription.amount_paid).to eq(100.0)
        expect(subscription.current_period_paid?).to be true
        expect(payment_scheduler).not_to have_received(:schedule)
      end
    end

    context 'when payment attempt results in insufficient funds' do
      it 'continues to the next percentage' do
        responses = [
          Api::Payments::Response.new(status: 'insufficient_funds'),
          Api::Payments::Response.new(status: 'insufficient_funds'),
          Api::Payments::Response.new(status: 'success')
        ]
        allow(payment_processor).to receive(:attempt_payment).and_return(*responses)

        expect(payment_processor).to receive(:attempt_payment).exactly(3).times

        billing_service.bill(subscription)

        expect(subscription.amount_paid).to eq(50.0)
        expect(subscription.current_period_paid?).to be false
        expect(payment_scheduler).to have_received(:schedule).with(subscription: subscription, date: Date.today + 7)
      end
    end

    context 'when all payment attempts fail' do
      it 'does not schedule rebilling' do
        response = Api::Payments::Response.new(status: 'failed')
        allow(payment_processor).to receive(:attempt_payment).and_return(response)

        expect(payment_processor).to receive(:attempt_payment)

        billing_service.bill(subscription)

        expect(subscription.amount_paid).to eq(0.0)
        expect(subscription.current_period_paid?).to be false
        expect(payment_scheduler).not_to have_received(:schedule)
      end
    end

    context 'when an exception occurs during billing' do
      it 'raises an error' do
        allow(payment_processor).to receive(:attempt_payment).and_raise(StandardError.new('Test exception'))

        expect {
          billing_service.bill(subscription)
        }.to raise_error(StandardError)
      end
    end
  end

  describe '#rebill' do
    context 'when subscription is already fully paid' do
      it 'does not attempt to rebill and logs paid status' do
        subscription.add_payment(100.0)
        expect(RebillLogger).to receive(:log).with("Subscription #{subscription.id} is already fully paid.")
        expect(payment_processor).not_to receive(:attempt_payment)
        billing_service.rebill(subscription)
      end
    end

    context 'when subscription is not fully paid' do
      before do
        allow(payment_processor).to receive(:attempt_payment)
      end

      it 'attempts to charge the remaining amount' do
        response = Api::Payments::Response.new(status: 'success')
        allow(payment_processor).to receive(:attempt_payment).and_return(response)

        billing_service.rebill(subscription)

        expect(subscription.amount_paid).to eq(100.0)
        expect(subscription.current_period_paid?).to be true
      end

      it 'does not schedule another rebilling if payment fails' do
        response = Api::Payments::Response.new(status: 'failed')
        allow(payment_processor).to receive(:attempt_payment).and_return(response)

        expect(payment_scheduler).not_to receive(:schedule)

        billing_service.rebill(subscription)

        expect(subscription.amount_paid).to eq(0.0)
        expect(subscription.current_period_paid?).to be false
      end

      it 'handles success payment during rebilling' do
        response = Api::Payments::Response.new(status: 'success')
        allow(payment_processor).to receive(:attempt_payment).and_return(response)
        expect(RebillLogger).to receive(:log).with("Remaining balance for subscription #{subscription.id}: $0.0.")

        billing_service.rebill(subscription)

        expect(subscription.amount_paid).to eq(100.0)
        expect(subscription.current_period_paid?).to be true
      end

      it 'raises an error if exception occurs during rebilling' do
        allow(payment_processor).to receive(:attempt_payment).and_raise(StandardError.new('Rebilling exception'))

        expect {
          billing_service.rebill(subscription)
        }.to raise_error(StandardError)
      end
    end
  end
end