require 'pisoni'

module AMP
  module Toolkit
    module Buddhi
      class Backend
        def self.run(test_plan)
          ThreeScale::Core.url = test_plan.internal_backend
          ThreeScale::Core.username = test_plan.backend_username
          ThreeScale::Core.password = test_plan.backend_password

          test_plan.services.each(&method(:create_service))
          test_plan.service_tokens.each(&method(:create_service_token))
          test_plan.metrics.each(&method(:create_metric))
          test_plan.usage_limits.each(&method(:create_usage_limit))
          test_plan.applications.each(&method(:create_application))
          test_plan.application_keys.each(&method(:create_application_key))
        end

        def self.create_service(attributes)
          ThreeScale::Core::Service.save!(attributes)
        end

        def self.create_service_token(entity)
          ThreeScale::Core::ServiceToken.save!(entity)
        end

        def self.create_metric(attributes)
          ThreeScale::Core::Metric.save(attributes)
        end

        def self.create_usage_limit(attributes)
          ThreeScale::Core::UsageLimit.save(attributes)
        end

        def self.create_application(attributes)
          ThreeScale::Core::Application.save(attributes)
        end

        HAS_USER_KEY = ->(entity) { entity.key?(:user_key) }
        HAS_APP_KEY = ->(entity) { entity.key?(:value) }

        def self.create_application_key(key)
          case key
          when HAS_USER_KEY
            ThreeScale::Core::Application.save_id_by_key(key[:service_id],
                                                         key[:user_key],
                                                         key[:application_id])
          when HAS_APP_KEY
            ThreeScale::Core::ApplicationKey.save(key[:service_id],
                                                  key[:application_id],
                                                  key[:value])
          else
            raise "Unknown key: #{key}"
          end
        end
      end
    end
  end
end
