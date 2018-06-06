module AMP
  module Toolkit
    module Buddhi
      module Saas
        class TestPlan
          include Buddhi::TestPlan

          # array to implement probability distribution: { 0: 20%, 1: 70%, 2: 7%, 3: 3% }
          BACKEND_N_METRIC_ARY = ([0] * 20 + [1] * 70 + [2] * 7 + [3] * 3).freeze
          AMP_N_METRIC_ARY = ([1] * 70 + [2] * 20 + [3] * 10).freeze

          def amp_uri_path
            proxy_pattern(AMP_N_METRIC_ARY.sample)
          end

          def backend_metric_usage(service)
            # first metric is the parent 'hits'
            service[:metrics].values[1..BACKEND_N_METRIC_ARY.sample].each do |metric|
              yield metric
            end
          end
        end
      end
    end
  end
end
