module AMP
  module Toolkit
    module Buddhi
      # TestPlan Interface
      module TestPlan
        %i[apicast_service_info amp_path backend_path].each do |method_name|
          define_method(method_name) do
            raise 'Not Implemented'
          end
        end

        SERVICES_TEMPLATE = %i[id backend_version provider_key].freeze
        METRICS_TEMPLATE = %i[id service_id name parent_id].freeze
        APPLICATIONS_TEMPLATE = %i[id service_id state plan_id plan_name].freeze
        APPLICATION_KEY_TEMPLATE = %i[value user_key application_id service_id].freeze
        BACKEND_URL_PATH = '/transactions/authrep.xml'.freeze

        attr_reader :internal_backend, :backend_url, :backend_username, :backend_password, :http_port

        def initialize(services, opts)
          @internal_backend = opts[:internal_api]
          @backend_url = opts[:backend]
          @backend_username = opts[:username]
          @backend_password = opts[:password]
          @http_port = opts[:port]
          @services = services
          @endpoint = opts[:endpoint]
          @host = URI(opts[:apicast] || 'http://').host
        end

        def services
          @services.values.map do |service|
            service.select { |key, _| SERVICES_TEMPLATE.include? key }
          end
        end

        def service_tokens
          []
        end

        def metrics
          @services.values.flat_map do |metrics:, **|
            metrics.values.map do |metric|
              metric.select { |key, _| METRICS_TEMPLATE.include? key }
            end
          end
        end

        def usage_limits
          @services.values.flat_map { |usage_limits:, **| usage_limits }
        end

        def applications
          @services.values.flat_map do |applications:, **|
            applications.values.map do |app|
              app.select { |key, _| APPLICATIONS_TEMPLATE.include? key }
            end
          end
        end

        def application_keys
          @services.values.flat_map do |application_keys:, **|
            application_keys.map do |key|
              key.select { |k, _| APPLICATION_KEY_TEMPLATE.include? k }
            end
          end
        end

        def hosts_for(id)
          [[id, @host].compact.join('.')]
        end

        def app_auth_params(app_key)
          if app_key.key? :value
            {
              app_id: app_key[:application_id],
              app_key: app_key[:value]
            }
          else
            {
              user_key: app_key[:user_key]
            }
          end
        end

        def backend_uri(query_params)
          uri = URI::HTTP.build(path: BACKEND_URL_PATH, query: URI.encode_www_form(query_params))
          "#{uri.path}?#{uri.query}"
        end

        def apicast_service_obj(service)
          {
            id: service[:id],
            backend_authentication_type: 'provider_key',
            backend_authentication_value: service[:provider_key],
            backend_version: service[:backend_version],
            proxy: {
              api_backend: @endpoint,
              hosts: hosts_for(service[:id]),
              backend: {
                endpoint: @backend_url
              },
              # first metric is the parent 'hits'
              proxy_rules: service[:metrics].values.drop(1).each_with_index.map do |metric, idx|
                {
                  http_method: 'GET',
                  pattern: yield(metric, idx),
                  metric_system_name: metric[:name],
                  delta: 1
                }
              end
            }
          }
        end

        def amp_uri(path, query_params)
          URI::HTTP.build(path: path, query: URI.encode_www_form(query_params))
        end
      end
    end
  end
end
