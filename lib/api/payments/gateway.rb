module Api
  module Payments
    class Gateway < Api::Client
      include Api::Payments::Constants

      def create_payment_intent(amount:, subscription_id:)
        uri = URI.join(API_BASE_URL, CREATE_INTENT_ENDPOINT)
        request_body = { amount: amount, subscription_id: subscription_id }.to_json
        response = send_post_request(uri, request_body)
        Response.new(parse_response(response))
      end
    end
  end
end