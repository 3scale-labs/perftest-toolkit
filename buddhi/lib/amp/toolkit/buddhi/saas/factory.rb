module AMP
  module Toolkit
    module Buddhi
      module Saas
        class SaaSFactory
          include Buddhi::Generator

          def call(**options)
            TestPlan.new(generate(n_providers: 100, n_services: 3,
                                  n_metrics: 3, n_apps: 33, n_plans: 2,
                                  n_usage_limits: 1), options)
          end
        end
        Buddhi::Factory.register_generator(:saas, SaaSFactory.new)
      end
    end
  end
end
