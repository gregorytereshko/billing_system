class PaymentScheduler
  @@scheduled_transactions = []

  def self.schedule(subscription:, date:)
    transaction = {
      subscription_id: subscription,
      date: date
    }
    @@scheduled_transactions << transaction
    RebillLogger.log("Scheduled additional transaction for subscription #{subscription.id} on #{date}")
  end

  def self.process_scheduled_transactions(current_date = Date.today)
    due_transactions = @@scheduled_transactions.select { |t| t[:date] <= current_date }

    due_transactions.each do |transaction|
      process_transaction(transaction)
      @@scheduled_transactions.delete(transaction)
    end
  end

  private

  def self.process_transaction(transaction)
    BillingService.new.rebill(subscription: transaction[:subscription])
  rescue StandardError => e
    RebillLogger.log("An error occurred while processing scheduled transaction: #{e.message}")
  end
end