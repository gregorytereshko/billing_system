# frozen_string_literal: true

module Api
  module Payments
    module Constants
      API_BASE_URL = 'http://localhost:4567'
      CREATE_INTENT_ENDPOINT = '/paymentIntents/create'

      STATUS_SUCCESS = 'success'
      STATUS_FAILED = 'failed'
      STATUS_INSUFFICIENT_FUNDS = 'insufficient_funds'
    end
  end
end
