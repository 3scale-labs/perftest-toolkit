module AMP
  module Toolkit
    module Buddhi
      module Profiles
        # Standard profile defintion
        # 1 account
        # # 10000 applications
        #
        # 100 products
        # # 1 Application plan per product
        # # 10 application plan limits per product
        # # 100 applications under each plan
        # # 10 backends used per product
        #
        # 1000 backends
        # # 50 Methods per backend
        # # 50 MappingRules per backend
        class Standard
          SERVICES_N = 100
          APP_PER_PLAN_N = 100
          BACKEND_PER_SVC_N = 10
          METHODS_PER_BACKEND_N = 50
          LIMITS_PER_PRODUCT = 10
          THREADS_N = Integer(ENV.fetch("THREADS_N", "10"))

          def self.call(portal, private_base_url, public_base_url)
            client = ThreeScale.client(portal)
            account = ThreeScale::Helper.create_account(client)
            services = Concurrent::Array.new
            # array with the number of services for each thread
            thread_tasks = [SERVICES_N/THREADS_N]*THREADS_N
            # Remaining shared between threads
            thread_tasks[0, SERVICES_N%THREADS_N] = thread_tasks[0, SERVICES_N%THREADS_N].map { |x| x + 1 }

            # threads array
            threads = thread_tasks.each_with_index.map do |n_tasks, idx|
              Thread.new(idx, account, private_base_url, public_base_url, services, n_tasks) do |i, acc, priv_url, pub_url, s_list, n|
                n.times do
                  standard = Standard.new(i, portal, priv_url, pub_url, acc)
                  standard.run
                  s_list << standard.service_id
                rescue => e
                  STDERR.puts e
                end
              end
            end

            # run all threads
            threads.each(&:join)

            services
          end

          attr_reader :client, :account, :service, :private_base_url, :public_base_url, :idx

          def initialize(idx, portal, private_base_url, public_base_url, account)
            @idx = idx
            @client = ThreeScale.client(portal)
            @private_base_url = private_base_url
            @public_base_url = public_base_url
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

            APP_PER_PLAN_N.times do |app_idx|
              ThreeScale::Helper.create_application(client, plan, account)
            end

            backends = nil
            begin
              backends = Array.new(BACKEND_PER_SVC_N) do |backend_idx|
                new_backend(client, private_base_url, service, backend_idx)
              end
            rescue ::ThreeScale::API::HttpClient::ForbiddenError
              raise 'Provider account does not support backend profile. ' \
                      'Upgrade account to API as Product model or choose another profile.'
            end

            method_iter = backends.lazy.flat_map do |backend|
              ThreeScale::Helper.backend_methods(client, backend)
            end

            method_iter.take(LIMITS_PER_PRODUCT).each do |method|
              ThreeScale::Helper.create_application_plan_limit(client, service, plan, method.fetch('id'))
            end

            ThreeScale::Helper.bump_proxy_conf(client, service)
            ThreeScale::Helper.promote_proxy_conf(client, service)
          end

          private

          def new_backend(client, private_base_url, service, backend_idx)
            backend = ThreeScale::Helper.create_backend(client, private_base_url)
            ThreeScale::Helper.create_backend_usage(client, service, backend, "/v#{idx}/#{format('v%04d', backend_idx)}")
            METHODS_PER_BACKEND_N.times do |method_idx|
              backend_method = ThreeScale::Helper.create_backend_method(client, backend)
              ThreeScale::Helper.create_backend_mapping_rule(client, backend, backend_method, format('/v%04d', method_idx))
            end

            backend
          end
        end

        Register.register_profile(:standard) { |portal, private_base_url, public_base_url| Standard.call(portal, private_base_url, public_base_url) }
      end
    end
  end
end
