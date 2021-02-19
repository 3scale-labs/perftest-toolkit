module AMP
  module Toolkit
    module Buddhi
      module Profiles

        # Backend profile defintion
        # 1 account
        # # 1 applications
        #
        # 1 product
        # # 1 Application plan per product
        # # 1 application plan limits per product
        # # 1 backends used per product
        # # 0 Method per product
        # # 0 MappingRules per product
        #
        # 1 backend
        # # 1 Method per backend
        # # 1 MappingRule per backend
        class Backend
          def self.call(portal, private_base_url, public_base_url)
            client = ThreeScale.client(portal)
            service = ThreeScale::Helper.create_service(client, public_base_url)
            ThreeScale::Helper.update_service_proxy(client, service, public_base_url)
            plan = ThreeScale::Helper.create_application_plan(client, service)
            account = ThreeScale::Helper.account(client)
            ThreeScale::Helper.create_application(client, plan, account)
            ThreeScale::Helper.delete_mapping_rules(client, service)
            begin
              backend = ThreeScale::Helper.create_backend(client, private_base_url)
              ThreeScale::Helper.create_backend_usage(client, service, backend, '/')
              backend_method = ThreeScale::Helper.create_backend_method(client, backend)
              ThreeScale::Helper.create_application_plan_limit(client, service, plan, backend_method.fetch('id'))
              ThreeScale::Helper.create_backend_mapping_rule(client, backend, backend_method, '/pets')
            rescue ::ThreeScale::API::HttpClient::ForbiddenError
              raise 'Provider account does not support backend profile. ' \
                      'Upgrade account to API as Product model or choose another profile.'
            end
            ThreeScale::Helper.bump_proxy_conf(client, service)
            ThreeScale::Helper.promote_proxy_conf(client, service)
            return [service.fetch('id')]
          end
        end

        Register.register_profile(:backend) { |portal, private_base_url, public_base_url| Backend.call(portal, private_base_url, public_base_url) }
      end
    end
  end
end
