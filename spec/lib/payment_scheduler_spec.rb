RSpec.describe PaymentScheduler do
  let(:subscription) { Subscription.new(id: 'sub_12345', price: 100.0, subscription_type: :monthly, start_date: Date.today) }
  let(:billing_service) { instance_double('BillingService') }

  before do
    allow(BillingService).to receive(:new).and_return(billing_service)
    allow(billing_service).to receive(:rebill)
    described_class.class_variable_set(:@@scheduled_transactions, [])
  end

  describe '.schedule' do
    it 'adds a transaction to the scheduled_transactions' do
      expect {
        described_class.schedule(subscription: subscription, date: Date.today + 7)
      }.to change { described_class.class_variable_get(:@@scheduled_transactions).size }.by(1)
    end
  end

  describe '.process_scheduled_transactions' do
    before do
      described_class.schedule(subscription: subscription, date: Date.today - 1)
      described_class.schedule(subscription: subscription, date: Date.today + 1)
    end

    it 'processes due transactions' do
      expect(billing_service).to receive(:rebill).once
      described_class.process_scheduled_transactions
      expect(described_class.class_variable_get(:@@scheduled_transactions).size).to eq(1)
    end
  end
end