RSpec.describe Subscription do
  let(:id) { 'sub_12345' }
  let(:price) { 100.0 }
  let(:subscription_type) { :monthly }
  let(:start_date) { Date.today }
  let(:subscription) do
    Subscription.new(
      id: id,
      price: price,
      subscription_type: subscription_type,
      start_date: start_date
    )
  end

  describe '#initialize' do
    it 'initializes with correct attributes' do
      expect(subscription.id).to eq(id)
      expect(subscription.price).to eq(price)
      expect(subscription.subscription_type).to eq(subscription_type)
      expect(subscription.start_date).to eq(start_date)
      expect(subscription.amount_paid).to eq(0.0)
    end
  end

  describe '#add_payment' do
    it 'adds payment to amount_paid' do
      subscription.add_payment(25.0)
      expect(subscription.amount_paid).to eq(25.0)
    end
  end

  describe '#current_period_paid?' do
    it 'returns false if amount_paid is less than price' do
      subscription.add_payment(50.0)
      expect(subscription.current_period_paid?).to be false
    end

    it 'returns true if amount_paid is equal to price' do
      subscription.add_payment(100.0)
      expect(subscription.current_period_paid?).to be true
    end

    it 'returns true if amount_paid is greater than price' do
      subscription.add_payment(150.0)
      expect(subscription.current_period_paid?).to be true
    end
  end

  describe '#active?' do
    it 'returns true if current date is within start_date and end_date and current_period_paid? is true' do
      subscription.add_payment(100.0)
      expect(subscription.active?).to be true
    end

    it 'returns false if current date is outside start_date and end_date' do
      allow(Date).to receive(:today).and_return(subscription.end_date + 1)
      subscription.add_payment(100.0)
      expect(subscription.active?).to be false
    end

    it 'returns false if current_period_paid? is false' do
      expect(subscription.active?).to be false
    end
  end

  describe '#remaining_amount' do
    it 'calculates the remaining amount correctly' do
      subscription.add_payment(30.0)
      expect(subscription.remaining_amount).to eq(70.0)
    end
  end
end