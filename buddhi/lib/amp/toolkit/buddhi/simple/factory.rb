module AMP
  module Toolkit
    module Buddhi
      module Simple
        class SimpleFactory
          include Buddhi::Generator

          def call(**options)
            TestPlan.new(generate(n_providers: 1, n_services: 1,
                                  n_metrics: 1, n_apps: 1, n_plans: 1,
                                  n_usage_limits: 1), options)
          end
        end
        Buddhi::Factory.register_generator(:simple, SimpleFactory.new)
      end
    end
  end
end
