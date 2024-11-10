class PaymentProcessor
  MAX_RETRIES = 4

  def initialize(payment_gateway = Api::Payments::Gateway.new)
    @payment_gateway = payment_gateway
  end

  def attempt_payment(amount:, subscription_id:)
    current_try = 0
    response = {}

    loop do
      current_try += 1
      response = @payment_gateway.create_payment_intent(amount: amount, subscription_id: subscription_id)
      process_response(response, amount, subscription_id)
      break if !response.failed? || current_try == MAX_RETRIES
    end

    response
  end

  private

  def process_response(response, amount, subscription_id)
    case response.status
    when 'success'
      RebillLogger.log("Successfully charged $#{amount} for subscription #{subscription_id}.")
    when 'insufficient_funds'
      RebillLogger.log("Insufficient funds for $#{amount} on subscription #{subscription_id}.")
    when 'failed'
      RebillLogger.log("Payment failed for $#{amount} on subscription #{subscription_id}.")
    else
      RebillLogger.log("Unknown status '#{response.status}' for $#{amount} on subscription #{subscription_id}.")
    end

    response
  end
end