require_relative 'config/boot'

# The default balance is $75.0 per card
# see payment_gateway_api.rb:11 (@@card_balances)
RebillLogger.log("For testing purposes the default balance is $75.0 per card.")

subscription_100 = Subscription.new(
  id: '$100_sub',
  price: 100.0,
  subscription_type: :monthly,
  start_date: Date.today
)

subscription_75 = Subscription.new(
  id: '$75_sub',
  price: 75.0,
  subscription_type: :monthly,
  start_date: Date.today
)

subscription_50 = Subscription.new(
  id: '$50_sub',
  price: 50.0,
  subscription_type: :monthly,
  start_date: Date.today
)

BillingService.new.bill(subscription_100)
BillingService.new.bill(subscription_75)
BillingService.new.bill(subscription_50)

BillingService.new.rebill(subscription_100)
