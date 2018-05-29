module AMP
  module Toolkit
    module Buddhi
      module OnPremises
        class OnPremFactory
          include Buddhi::Generator

          def call(**options)
            # Saas test plan is valid for onPrem
            Buddhi::Saas::TestPlan.new(generate(n_providers: 1, n_services: 3,
                                                n_metrics: 3, n_apps: 100, n_plans: 3,
                                                n_usage_limits: 2), options)
          end
        end
        Buddhi::Factory.register_generator(:onprem, OnPremFactory.new)
      end
    end
  end
end
