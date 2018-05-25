module AMP
  module Toolkit
    module Buddhi
      module Saas
        class TestPlan
          include Buddhi::TestPlan

          # array to implement probability distribution: { 0: 20%, 1: 70%, 2: 7%, 3: 3% }
          BACKEND_N_METRIC_ARY = ([0] * 20 + [1] * 70 + [2] * 7 + [3] * 3).freeze
          AMP_N_METRIC_ARY = ([1] * 70 + [2] * 20 + [3] * 10).freeze

          def apicast_service_info(id)
            return unless @services.key? id
            apicast_service_obj(@services[id]) { |_, idx| proxy_pattern(idx + 1) }
          end

          def amp_path
            host, path = amp_path_sample
            %("#{host}","#{path}")
          end

          def amp_path_sample
            service = @services.values.sample
            app_key = service[:application_keys].sample
            app_id_auth = app_auth_params app_key
            uri = amp_uri(proxy_pattern(AMP_N_METRIC_ARY.sample), app_id_auth)
            [hosts_for(service[:id]).first, "#{uri.path}?#{uri.query}"]
          end

          def proxy_pattern(n)
            format('/%<path>s', path: '1' * n)
          end

          def backend_path
            service = @services.values.sample
            app_key = service[:application_keys].sample
            metrics = service[:metrics].values
            app_id_auth = app_auth_params app_key

            query = {
              provider_key: service[:provider_key],
              service_id: service[:id]
            }.merge(app_id_auth)

            BACKEND_N_METRIC_ARY.sample.times do |idx|
              query["usage[#{metrics[idx][:name]}]".to_sym] = 1
            end
            backend_uri(query)
          end
        end
      end
    end
  end
end
