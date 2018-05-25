module AMP
  module Toolkit
    module Buddhi
      module Simple
        class TestPlan
          include Buddhi::TestPlan

          AMP_URL_PATH_TEMPLATE = '/%<metric>s/some-request'.freeze

          def apicast_service_info(id)
            return unless @services.key? id
            apicast_service_obj(@services[id]) { |metric, _| "/#{metric[:name]}/" }
          end

          def amp_path
            host, path = amp_path_sample
            %("#{host}","#{path}")
          end

          def amp_path_sample
            service = @services.values.first
            # first metric is the parent 'hits'
            metric = service[:metrics].values.drop(1).first
            app_key = service[:application_keys].first
            app_id_auth = app_auth_params app_key

            uri = amp_uri(format(AMP_URL_PATH_TEMPLATE, metric: metric[:name]), app_id_auth)
            [hosts_for(service[:id]).first, "#{uri.path}?#{uri.query}"]
          end

          def backend_path
            service = @services.values.first
            # first metric is the parent 'hits'
            metric = service[:metrics].values.drop(1).first
            app_key = service[:application_keys].first
            app_id_auth = app_auth_params app_key

            query = {
              provider_key: service[:provider_key],
              service_id: service[:id]
            }.merge(app_id_auth)
            query["usage[#{metric[:name]}]".to_sym] = 1
            backend_uri(query)
          end
        end
      end
    end
  end
end
