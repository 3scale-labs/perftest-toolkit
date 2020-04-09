module AMP
  module Toolkit
    module ThreeScale
      module Helper
        def self.random_lowercase_name
          [*('a'..'z')].sample(8).join
        end

        def self.parse_uri(uri)
          # raises error when remote_str is not string, but object or something else.
          uri_obj = URI(uri)
          # URI::HTTP is parent of URI::HTTPS
          # with single check both types are checked
          raise "invalid url: #{uri}" unless uri_obj.kind_of?(URI::HTTP)

          uri_obj
        end

        def self.create_service(client)
          service_name = "PERF_TEST_#{random_lowercase_name}"
          system_name = service_name.delete("\s").downcase
          svc_params = { 'name' => service_name, 'system_name' => system_name }
          svc_obj = client.create_service svc_params

          if (errors = svc_obj['errors'])
            raise "Service has not been created: #{errors}"
          end

          svc_obj
        end

        def self.create_application_plan(client, service)
          name = random_lowercase_name
          plan_params = {
            'name' => name, 'state' => 'published', 'default' => false,
            'custom' => false, 'system_name' => name
          }

          plan_obj = client.create_application_plan service.fetch('id'), plan_params
          if (errors = plan_obj['errors'])
            raise "Application plan has not been created: #{errors}"
          end

          plan_obj
        end

        def self.hits_metric(client, service)
          metrics = client.list_metrics service.fetch('id')
          if metrics.respond_to?(:has_key?) && (errors = metrics['errors'])
            raise "Service metrics not read: #{errors}"
          end

          hits_metric_obj = metrics.find { |metric| metric['system_name'] == 'hits' }
          raise "Missing hits metric in service #{service.fetch('id')}" if hits_metric_obj.nil?

          hits_metric_obj
        end

        def self.create_application_plan_limit(client, service, plan)
          hits_metric_obj = hits_metric(client, service)

          # Very high limit: 4294967295 / 3600 => 1.2 M req/second during one hour to go over limit
          limit_params = { 'period' => 'hour', 'value' => 2**32 - 1 }
          limit_obj = client.create_application_plan_limit(
            plan.fetch('id'),
            hits_metric_obj.fetch('id'),
            limit_params
          )
          if (errors = limit_obj['errors'])
            raise "Limit has not been created: #{errors}"
          end

          limit_obj
        end

        def self.delete_mapping_rules(client, service)
          mapping_rules = client.list_mapping_rules service.fetch('id')
          if mapping_rules.respond_to?(:has_key?) && (errors = mapping_rules['errors'])
            raise "Service mapping rules not read: #{errors}"
          end

          mapping_rules.each do |mapping_rule|
            client.delete_mapping_rule service.fetch('id'), mapping_rule.fetch('id')
          end
        end

        def self.create_mapping_rule(client, service, path)
          hits_metric_obj = hits_metric(client, service)
          mapping_rule_params = {
            'metric_id' => hits_metric_obj.fetch('id'), 'pattern' => path,
            'http_method' => 'GET',
            'delta' => 1
          }

          mapping_rule_obj = client.create_mapping_rule service.fetch('id'), mapping_rule_params
          if (errors = mapping_rule_obj['errors'])
            raise "MappingRule has not been created: #{errors}"
          end

          mapping_rule_obj
        end

        def self.create_application(client, plan, account)
          app_params = {
            'name' => "app_#{random_lowercase_name}",
            'description' => "app #{random_lowercase_name}"
          }

          app_obj = client.create_application(account.fetch('id'), app_params, plan_id: plan.fetch('id'))
          if (errors = app_obj['errors'])
            raise "Application has not been created: #{errors}"
          end

          app_obj
        end

        def self.account(client)
          accounts = client.list_accounts
          if accounts.respond_to?(:has_key?) && (errors = accounts['errors'])
            raise "Accounts not read: #{errors}"
          end

          raise 'No accounts available' if accounts.length.zero?

          accounts[0]
        end

        def self.create_backend(client, endpoint)
          attrs = {
            name: random_lowercase_name,
            private_endpoint: endpoint,
          }

          backend_obj = client.create_backend(attrs)
          if backend_obj.respond_to?(:has_key?) && (errors = backend_obj['errors'])
            raise "Backend not created: #{errors}"
          end

          backend_obj
        end

        def self.create_backend_usage(client, product, backend, path)
          attrs = {
            backend_api_id: backend.fetch('id'),
            path: path
          }

          backend_usage_obj = client.create_backend_usage(product.fetch('id'), attrs)
          if backend_usage_obj.respond_to?(:has_key?) && (errors = backend_usage_obj['errors'])
            raise "Backend usage not created: #{errors}"
          end

          backend_usage_obj
        end

        def self.bump_proxy_conf(client, service)
          proxy_settings = {
            # Adding harmless attribute to avoid empty body
            # update_proxy cannot be done with empty body
            # and must be done to increase proxy version
            # If proxy settings have not been changed since last update,
            # this request will not have effect and proxy config version will not be bumped.
            service_id: service.fetch('id')
          }
          new_proxy_attrs = client.update_proxy service.fetch('id'), proxy_settings
          if (errors = new_proxy_attrs['errors'])
            raise "Proxy config not bumped: #{errors}"
          end

          wait do
            pc_sandbox = client.proxy_config_latest(service.fetch('id'), 'sandbox')
            if (errors = pc_sandbox['errors'])
              raise "Proxy config not read: #{errors}"
            end

            !pc_sandbox.nil?
          end

          new_proxy_attrs
        end

        def self.promote_proxy_conf(client, service)
          sandbox_proxy_cfg = client.proxy_config_latest(service.fetch('id'), 'sandbox')
          if (errors = sandbox_proxy_cfg['errors'])
            raise "Sandbox Proxy config not read: #{errors}"
          end

          res = client.promote_proxy_config(
            service.fetch('id'),
            'sandbox',
            sandbox_proxy_cfg.fetch('version'),
            'production'
          )
          if (errors = res['errors'])
            raise "Proxy not promoted: #{errors}"
          end

          res
        end

        def self.backend_hits_metric(client, backend)
          metrics = client.list_backend_metrics backend.fetch('id')
          if metrics.respond_to?(:has_key?) && (errors = metrics['errors'])
            raise "Backend metrics not read: #{errors}"
          end

          hits_metric_obj = metrics.find { |metric| metric['system_name'].include? 'hits' }
          raise "Missing hits metric in backend #{backend.fetch('id')}" if hits_metric_obj.nil?

          hits_metric_obj
        end

        def self.create_backend_mapping_rule(client, backend, method, path)
          mapping_rule_params = {
            'metric_id' => method.fetch('id'), 'pattern' => path,
            'http_method' => 'GET',
            'delta' => 1
          }

          mapping_rule_obj = client.create_backend_mapping_rule backend.fetch('id'), mapping_rule_params
          if (errors = mapping_rule_obj['errors'])
            raise "Backend MappingRule has not been created: #{errors}"
          end

          mapping_rule_obj
        end

        def self.create_backend_method(client, backend)
          hits_metric_obj = backend_hits_metric(client, backend)
          attrs = {
            'system_name' => random_lowercase_name,
            'friendly_name' => random_lowercase_name,
            'description' => random_lowercase_name
          }
          method_obj = client.create_backend_method(backend.fetch('id'), hits_metric_obj.fetch('id'), attrs)

          if (errors = method_obj['errors'])
            raise "Method has not been created: #{errors}"
          end

          method_obj
        end

        # wait tries a block of code until it returns true, or the timeout is reached.
        # timeout give an upper limit to the amount of time this method will run
        # Some intervals may be missed if the block takes too long or the time window is too short.
        def self.wait(interval = 1.5, timeout = 30)
          raise 'wait expects block' unless block_given?

          end_time = Time.now + timeout
          until Time.now > end_time
            result = yield
            return if result == true

            sleep interval
          end

          raise "timed out after #{timeout} seconds"
        end
      end
    end
  end
end
