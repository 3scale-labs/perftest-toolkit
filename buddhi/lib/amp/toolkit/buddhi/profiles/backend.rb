module AMP
  module Toolkit
    module Buddhi
      module Profiles
        class Backend
          def call(client, endpoint:, **_options)
            service = ThreeScale::Helper.create_service(client)
            plan = ThreeScale::Helper.create_application_plan(client, service)
            account = ThreeScale::Helper.account(client)
            ThreeScale::Helper.create_application(client, plan, account)
            ThreeScale::Helper.create_application_plan_limit(client, service, plan)
            ThreeScale::Helper.delete_mapping_rules(client, service)
            backend = ThreeScale::Helper.create_backend(client, endpoint)
            backend_method = ThreeScale::Helper.create_backend_method(client, backend)
            ThreeScale::Helper.create_backend_mapping_rule(client, backend, backend_method, '/pets')
            ThreeScale::Helper.create_backend_usage(client, service, backend, '/')
            ThreeScale::Helper.bump_proxy_conf(client, service)
            ThreeScale::Helper.promote_proxy_conf(client, service)
            return service.fetch('id')
          end
        end
        Register.register_profile(:backend, Backend.new)
      end
    end
  end
end
