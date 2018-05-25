require 'securerandom'

module AMP
  module Toolkit
    module Buddhi
      module Generator
        def call(_opts)
          raise 'Not Implemented'
        end

        def generate(n_providers:, n_services:, n_metrics:,
                     n_apps:, n_plans:, n_usage_limits:)
          p_keys = provider_keys n_providers
          svcs = services p_keys, n_services
          metrics svcs, n_metrics
          plans svcs, n_plans
          apps = applications svcs, n_apps
          application_keys apps
          usage_limits svcs, n_usage_limits
          svcs
        end

        private

        def provider_keys(n)
          Array.new(n) { generate_provider_key }
        end

        def services(provider_keys, n)
          provider_keys.each_with_object({}) do |provider_key, acc|
            services_per_provider(provider_key, n).map do |service|
              acc[service[:id]] = service
            end
          end
        end

        def services_per_provider(provider_key, n)
          Array.new(n) { generate_service provider_key }
        end

        def metrics(services, n)
          services.each_value do |service|
            metrics_per_service service, n
          end
        end

        def metrics_per_service(service, n)
          hits_metric = generate_metric service
          service[:metrics][hits_metric[:id]] = hits_metric
          n.times do
            metric = generate_metric service, parent_id: hits_metric[:id]
            service[:metrics][metric[:id]] = metric
          end
        end

        def plans(services, n)
          services.each_value do |service|
            n.times do
              plan = generate_plan service
              service[:plans][plan[:id]] = plan
            end
          end
        end

        def applications(services, n)
          services.values.flat_map do |service|
            plans = service[:plans]
            plans_keys = plans.keys
            Array.new(n) do
              # Assign applications to plans randomly
              app = generate_application service, plans[plans_keys.sample]
              service[:applications][app[:id]] = app
              app
            end
          end
        end

        PERIODS = %i[hour day week month year eternity].freeze

        def usage_limits(services, n_per_metric_plan)
          services.each_value do |service|
            metrics = service[:metrics].values.map { |id:, **| id }
            plans = service[:plans].values.map { |id:, **| id }
            metrics.product(plans).each do |metric, plan|
              PERIODS.take(n_per_metric_plan).each do |period|
                u_l = generate_usage_limit({ period => 1e9 },
                                           service: service[:id], metric: metric, plan: plan)
                service[:usage_limits] << u_l
              end
            end
          end
        end

        def application_keys(apps)
          apps.each do |app|
            key = case (backend_version = app[:service][:backend_version])
                  when '1', 1
                    generate_user_key(app)
                  when '2', 2
                    generate_application_key(app)
                  else
                    raise "Unknown backend version: #{backend_version}"
                  end
            app[:keys] << key
            app[:service][:application_keys] << key
          end
        end

        BACKEND_VERSIONS = %w[1 2].freeze

        def generate_provider_key
          {
            id: SecureRandom.uuid
          }
        end

        def generate_service(provider_key, backend_version = BACKEND_VERSIONS.sample)
          {
            id: SecureRandom.uuid,
            backend_version: backend_version,
            provider_key: provider_key[:id],
            metrics: {},
            plans: {},
            applications: {},
            application_keys: [],
            usage_limits: []
          }
        end

        def generate_metric(service, parent_id: nil)
          {
            service_id: service[:id],
            service: service,
            id: id = SecureRandom.uuid,
            name: id,
            parent_id: parent_id
          }
        end

        def generate_plan(service)
          {
            id: id = SecureRandom.uuid,
            name: id,
            service: service,
            service_id: service[:id]
          }
        end

        def generate_application(service, plan)
          {
            service: service,
            service_id: service[:id],
            id: SecureRandom.hex(8),
            state: 'active'.freeze,
            plan: plan,
            plan_id: plan[:id],
            plan_name: plan[:name],
            keys: []
          }
        end

        def generate_application_key(app)
          {
            value: SecureRandom.hex(8),
            application: app,
            application_id: app[:id],
            service: app[:service],
            service_id: app[:service][:id]
          }
        end

        def generate_user_key(app)
          {
            user_key: SecureRandom.hex(8),
            application: app,
            application_id: app[:id],
            service: app[:service],
            service_id: app[:service][:id]
          }
        end

        def generate_usage_limit(limit, service:, metric:, plan:)
          {
            service_id: service,
            metric_id: metric,
            plan_id: plan
          }.merge(limit)
        end
      end
    end
  end
end
