module AMP
  module Toolkit
    module Buddhi
      module Profiles
        class MultiService
          THREADS_N = Integer(ENV.fetch("THREADS_N", "10"))

          def self.call(portal:, services_n:, **opts)
            client = ThreeScale.client(portal)
            account = ThreeScale::Helper.create_account(client)
            services = Concurrent::Array.new
            # array with the number of services for each thread
            thread_tasks = [services_n/THREADS_N]*THREADS_N
            # Remaining shared between threads
            thread_tasks[0, services_n%THREADS_N] = thread_tasks[0, services_n%THREADS_N].map { |x| x + 1 }

            # threads array
            threads = thread_tasks.each_with_index.map do |n_tasks, idx|
              Thread.new(idx, account, services, n_tasks, portal, opts) do |i, acc, s_list, n, p, opts|
                n.times do
                  multi_service = MultiService.new(i, p, acc, opts)
                  multi_service.run
                  puts "Service #{multi_service.service_id}"
                  s_list << multi_service.service_id
                rescue => e
                  STDERR.puts e
                end
              end
            end

            # run all threads
            threads.each(&:join)

            services
          end

          attr_reader :client, :account, :service, :private_base_url, :public_base_url, :idx,
                      :backend_per_svc_n, :app_per_plan_n, :methods_per_backend_n, :limits_per_product

          def initialize(idx, portal, account, opts)
            @idx = idx
            @client = ThreeScale.client(portal)
            @private_base_url = opts.fetch(:private_base_url)
            @public_base_url = opts.fetch(:public_base_url)
            @backend_per_svc_n = opts.fetch(:backend_per_svc_n)
            @app_per_plan_n = opts.fetch(:app_per_plan_n)
            @methods_per_backend_n = opts.fetch(:methods_per_backend_n)
            @limits_per_product = opts.fetch(:limits_per_product)
            @service = ThreeScale::Helper.create_service(client, public_base_url)
            @account = account
          end

          def service_id
            service.fetch('id')
          end

          def run
            ThreeScale::Helper.update_service_proxy(client, service, public_base_url)
            ThreeScale::Helper.delete_mapping_rules(client, service)
            plan = ThreeScale::Helper.create_application_plan(client, service)

            app_per_plan_n.times do |app_idx|
              ThreeScale::Helper.create_application(client, plan, account)
            end

            backends = nil
            begin
              backends = Array.new(backend_per_svc_n) do |backend_idx|
                new_backend(client, private_base_url, service, backend_idx)
              end
            rescue ::ThreeScale::API::HttpClient::ForbiddenError
              raise 'Provider account does not support backend profile. ' \
                      'Upgrade account to API as Product model or choose another profile.'
            end

            method_iter = backends.lazy.flat_map do |backend|
              ThreeScale::Helper.backend_methods(client, backend)
            end

            method_iter.take(limits_per_product).each do |method|
              ThreeScale::Helper.create_application_plan_limit(client, service, plan, method.fetch('id'))
            end

            ThreeScale::Helper.bump_proxy_conf(client, service)
            ThreeScale::Helper.promote_proxy_conf(client, service)
          end

          private

          def new_backend(client, private_base_url, service, backend_idx)
            backend = ThreeScale::Helper.create_backend(client, private_base_url)
            ThreeScale::Helper.create_backend_usage(client, service, backend, "/v#{idx}/#{format('v%04d', backend_idx)}")
            methods_per_backend_n.times do |method_idx|
              backend_method = ThreeScale::Helper.create_backend_method(client, backend)
              ThreeScale::Helper.create_backend_mapping_rule(client, backend, backend_method, format('/v%04d', method_idx))
            end

            backend
          end
        end
      end
    end
  end
end
