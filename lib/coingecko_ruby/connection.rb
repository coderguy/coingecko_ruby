require 'faraday'
require 'faraday_middleware'
require 'coingecko_ruby/error'

module CoingeckoRuby
  module Connection
    BASE_URL = "https://api.coingecko.com/api/v3/".freeze
    BASE_URL_PRO = "https://pro-api.coingecko.com/api/v3".freeze

    def get(endpoint, **opts)
      request :get, endpoint, **opts
    end

    def request(method, endpoint, **opts)
      connection = create_connection
      endpoint = endpoint + auth()
      response = connection.send(method, endpoint, opts)
      response.body
    rescue Faraday::Error => e
      wrapped_error_class = CoingeckoRuby::FaradayError.wrap_error(e)
      raise wrapped_error_class.new(e.message, response)
    end

    def create_connection
      url = url()

      connection = Faraday.new(url: url) do |c|
        c.use Faraday::Response::RaiseError
        c.request :retry, max: 5
        c.response :json
      end
      connection
    end

    def url
      if @client_version == "pro"
        BASE_URL_PRO
      else
        BASE_URL
      end
    end

    def auth
      if @client_version == "pro"
        "?x_cg_pro_api_key=" + ENV["COINBASE_PRO_API_KEY"]
      else
        ""
      end
    end
  end
end
