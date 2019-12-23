module AMP
  module Toolkit
    module ThreeScale
      ##
      # Input param can be endpoint url or remote name
      #
      def self.client(portal_url)
        remote_client(remote(portal_url))
      end

      def self.remote(uri_str)
        uri = Helper.parse_uri(uri_str)

        authentication = uri.user
        uri.user = ''
        { authentication: authentication, endpoint: uri.to_s }
      end

      def self.remote_client(endpoint:, authentication:)
        ::ThreeScale::API.new(endpoint: endpoint, provider_key: authentication, verify_ssl: false)
      end
    end
  end
end
