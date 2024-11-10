# config/boot.rb

# Require standard libraries
require 'logger'
require 'date'
require 'json'
require 'net/http'
require 'uri'
require 'date'

# Require all application files
require_relative '../lib/rebill_logger'
require_relative '../lib/api/api_client'
require_relative '../lib/api/payments/constants'
require_relative '../lib/api/payments/response'
require_relative '../lib/api/payments/gateway'
require_relative '../lib/payment_processor'
require_relative '../lib/billing_service'
require_relative '../lib/payment_scheduler'

require_relative '../app/models/subscription'