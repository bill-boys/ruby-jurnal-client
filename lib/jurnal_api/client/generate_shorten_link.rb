module JurnalApi
  class Client
    # Defines methods related to Core
    module GenerateShortenLink
      # params: {payment_url: 'https://example.com/payment'}
      def generate_shorten_link(params = {})
        self.api_version = 'api/internal'
        self.format = nil

        response = post("transactions/generate_shorten_link?payment_url=#{params[:payment_url]}", {}, false, true)

        response
      end
    end
  end
end
