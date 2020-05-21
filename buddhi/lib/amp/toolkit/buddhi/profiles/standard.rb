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

          def call(client, endpoint:, **_options)
            account = ThreeScale::Helper.create_account(client)

            Array.new(SERVICES_N) do
              service = ThreeScale::Helper.create_service(client)
              configure_service(client, endpoint, service, account)
              service.fetch('id')
            end
          end

          def configure_service(client, endpoint, service, account)
            ThreeScale::Helper.delete_mapping_rules(client, service)
            plan = ThreeScale::Helper.create_application_plan(client, service)

            APP_PER_PLAN_N.times do |app_idx|
              ThreeScale::Helper.create_application(client, plan, account)
            end

            backends = nil
            begin
              backends = Array.new(BACKEND_PER_SVC_N) do |backend_idx|
                new_backend(client, endpoint, service, backend_idx)
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

          def new_backend(client, endpoint, service, backend_idx)
            backend = ThreeScale::Helper.create_backend(client, endpoint)
            ThreeScale::Helper.create_backend_usage(client, service, backend, format('/v%04d', backend_idx))
            METHODS_PER_BACKEND_N.times do |method_idx|
              backend_method = ThreeScale::Helper.create_backend_method(client, backend)
              ThreeScale::Helper.create_backend_mapping_rule(client, backend, backend_method, format('/v%04d', method_idx))
            end

            backend
          end
        end

        Register.register_profile(:standard, Standard.new)
      end
    end
  end
end
