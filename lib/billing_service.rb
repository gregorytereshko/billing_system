class BillingService
  ATTEMPT_PERCENTAGES = [1.0, 0.75, 0.5, 0.25].freeze

  def initialize(payment_processor: PaymentProcessor.new, payment_scheduler: PaymentScheduler)
    @payment_processor = payment_processor
    @payment_scheduler = payment_scheduler
  end

  def bill(subscription)
    RebillLogger.log("Billing Subscription #{subscription.id}...")
    return log_paid_status(subscription) if subscription.current_period_paid?

    ATTEMPT_PERCENTAGES.each do |percentage|
      amount_to_charge = subscription.remaining_amount * percentage
      response = @payment_processor.attempt_payment(amount: amount_to_charge, subscription_id: subscription.id)

      next if response.insufficient_funds?

      if response.success?
        handle_success_payment(subscription, amount_to_charge)
        schedule_rebilling(subscription) if !subscription.current_period_paid?
        return
      end

      return
    end
  end

  def rebill(subscription)
    RebillLogger.log("Rebilling Subscription #{subscription.id}...")
    return log_paid_status(subscription) if subscription.current_period_paid?

    amount_to_charge = subscription.remaining_amount
    response = @payment_processor.attempt_payment(amount: amount_to_charge, subscription_id: subscription.id)

    handle_success_payment(subscription, amount_to_charge) if response.success?
  end

  private

  def schedule_rebilling(subscription)
    @payment_scheduler.schedule(subscription: subscription, date: Date.today + 7)
  end

  def handle_success_payment(subscription, amount_to_charge)
    subscription.add_payment(amount_to_charge)
    RebillLogger.log("Remaining balance for subscription #{subscription.id}: $#{subscription.remaining_amount}.")
  end

  def log_paid_status(subscription)
    RebillLogger.log("Subscription #{subscription.id} is already fully paid.")
  end
end