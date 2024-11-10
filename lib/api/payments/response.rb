module Api
  module Payments
    class Response
      def initialize(response)
        @response = response
      end

      def status
        @response[:status]
      end

      def success?
        status == 'success'
      end

      def failed?
        status == 'failed'
      end

      def insufficient_funds?
        status == 'insufficient_funds'
      end

      def unknown?
        !success? && !failed? && !insufficient_funds?
      end
    end
  end
end
