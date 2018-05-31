module AMP
  module Toolkit
    module Buddhi
      module Simple
        class TestPlan
          include Buddhi::TestPlan

          def amp_uri_path
            proxy_pattern(1)
          end

          def backend_metric_usage(service)
            # first metric is the parent 'hits'
            yield service[:metrics].values.drop(1).first
          end
        end
      end
    end
  end
end
