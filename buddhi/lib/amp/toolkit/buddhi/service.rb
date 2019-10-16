module AMP
  module Toolkit
    module Buddhi
      class Service
        attr_reader :client, :service_id

        def initialize(client, service_id)
          @client = client
          @service_id = service_id
        end

        def items
          [
            ["some.host.com", "/"],
            ["some.host.com", "/1"]
          ]
        end
      end
    end
  end
end
