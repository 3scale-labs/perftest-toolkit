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

          # When multiple applications exist, each mapping rule will be authorized by a random app
          # For services with app_id && app_key (backend_version 2)
          #   When multiple applications key exist,
          #   each mapping rule will be authorized by a random app key
          get_mapping_rules = mapping_rules.select { |mr| mr.fetch('http_method') == 'GET' }
          url_ary = get_mapping_rules.map(&method(:build_url))
          url_ary.map { |u| [u.host, u.request_uri] }
        end

        private

        def build_url(mapping_rule)
          URI::HTTP.build(
            host: service_host,
            path: cleaned_pattern(mapping_rule.fetch('pattern')),
            query: application_key_sample
          )
        end

        def cleaned_pattern(pattern)
          pattern.chomp('$')
        end

        def mapping_rules
          mapping_rule_list = product_mapping_rules + backend_mapping_rules
        end

        def product_mapping_rules
          client.list_mapping_rules service_id
        end

        def backend_mapping_rules
          backend_usages.flat_map do |backend_usage|
            client.list_backend_mapping_rules(backend_usage.fetch('backend_id')).map do |mp_rule|
              mp_rule.merge('pattern' => "#{backend_usage.fetch('path')}#{mp_rule['pattern']}")
            end
          end
        end

        def backend_usages
          client.list_backend_usages(service_id)
        rescue ::ThreeScale::API::HttpClient::ForbiddenError
          # 3scale Backends not supported
          []
        end

        def applications
          @applications ||= fetch_service_applications
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

        def fetch_service_applications
          client.list_applications(service_id: service_id)
        end

        def application_key_sample
          return nil if applications.empty?

          URI.encode_www_form(app_auth_params(applications.sample))
        end

        def app_auth_params(app)
          if app['application_id'].nil?
            {
              user_key: app['user_key']
            }
          else
            {
              app_id: app['application_id'],
              app_key: application_key(app)
            }
          end
        end

        def application_key(app)
          application_keys = client.list_application_keys(app['account_id'], app['id'])
          return nil if application_keys.empty?

          application_keys.sample['value']
        end
      end
    end
  end
end
