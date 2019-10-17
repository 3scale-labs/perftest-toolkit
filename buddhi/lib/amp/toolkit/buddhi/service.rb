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
          return [] if service_host.nil?

          get_mapping_rules = mapping_rules.select { |mr| mr.fetch('http_method') == 'GET' }
          get_mapping_rules.map { |mr| [service_host, cleaned_pattern(mr.fetch('pattern'))] }
        end

        private

        def cleaned_pattern(pattern)
          pattern.chomp('$')
        end

        def mapping_rules
          client.list_mapping_rules service_id
        end

        def service_host
          @service_host ||= parse_service_host
        end

        def parse_service_host
          endpoint_url = client.show_proxy(service_id).fetch('endpoint')
          if endpoint_url.empty?
            warn "service_id: #{service_id}: Production Public Base URL is empty"
            return nil
          end

          endpoint = ThreeScale::Helper.parse_uri(endpoint_url)
          endpoint.host
        end
      end
    end
  end
end
