class Subscription
  attr_reader :id, :price, :subscription_type, :start_date, :end_date, :amount_paid

  def initialize(id:, price:, subscription_type:, start_date:, amount_paid: 0.0)
    @id = id
    @price = price.to_f
    @subscription_type = subscription_type.to_sym # :monthly or :yearly
    @start_date = start_date
    @amount_paid = amount_paid.to_f
    @end_date = calculate_end_date
  end

  def add_payment(amount)
    amount = amount.to_f
    @amount_paid += amount
  end

  def active?
    Date.today >= @start_date && Date.today <= @end_date && current_period_paid?
  end

  def current_period_paid?
    @amount_paid >= @price
  end

  def next_period_start_date
    @end_date + 1.day
  end

  def remaining_amount
    @price - @amount_paid
  end

  private

  # Calculates the end date based on the subscription type
  def calculate_end_date
    case @subscription_type
    when :monthly
      @start_date >> 1
    when :yearly
      @start_date >> 12
    end
  end
end