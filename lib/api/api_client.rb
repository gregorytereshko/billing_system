module Api
  class Client
    protected

    def send_post_request(uri, body)
      request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      request.body = body

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end
    end

    def parse_response(response)
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body, symbolize_names: true)
      else
        RebillLogger.log("HTTP Error: #{response.code} #{response.message}")
        { status: 'failed' }
      end
    rescue JSON::ParserError => e
      RebillLogger.log("JSON parsing error: #{e.message}")
      { status: 'failed' }
    end
  end
end