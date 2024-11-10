# payment_gateway_api.rb
require 'sinatra'
require 'json'

# Sinatra settings
set :port, 4567
set :bind, '0.0.0.0'

# Simulate the payment gateway API
class PaymentGatewayAPI < Sinatra::Base
  @@card_balances = Hash.new { |hash, key| hash[key] = 75.0 } # Default balance of $75.0 per card

  post '/paymentIntents/create' do
    content_type :json

    request_payload = JSON.parse(request.body.read)
    amount = request_payload['amount'].to_f
    subscription_id = request_payload['subscription_id']

    # Get the card balance for the given subscription_id
    card_balance = @@card_balances[subscription_id]

    # Simulate API response
    if amount <= 0
      status = 'failed'
    elsif amount <= card_balance
      status = 'success'
      @@card_balances[subscription_id] -= amount
    else
      status = 'insufficient_funds'
    end

    { status: status }.to_json
  end
end

# Start the Sinatra application if this file is executed directly
if __FILE__ == $0
  PaymentGatewayAPI.run!
end