module AMP
  module Toolkit
    module Buddhi
      module Profiles
        class Simple
          def call(client, endpoint:, **_options)
            service = ThreeScale::Helper.create_service(client)
            plan = ThreeScale::Helper.create_application_plan(client, service)
            ThreeScale::Helper.create_application_plan_limit(client, service, plan)
            ThreeScale::Helper.delete_mapping_rules(client, service)
            ThreeScale::Helper.create_mapping_rule(client, service, '/pets')
            account = ThreeScale::Helper.account(client)
            ThreeScale::Helper.create_application(client, plan, account)
            begin
              backend = ThreeScale::Helper.create_backend(client, endpoint)
              ThreeScale::Helper.create_backend_usage(client, service, backend, '/')
            rescue ::ThreeScale::API::HttpClient::ForbiddenError
              # 3scale Backends not supported
              ThreeScale::Helper.update_private_endpoint(client, service, endpoint)
            end
            ThreeScale::Helper.bump_proxy_conf(client, service)
            ThreeScale::Helper.promote_proxy_conf(client, service)
            return service.fetch('id')
          end
        end
        Register.register_profile(:simple, Simple.new)
      end
    end
  end
end
