module AMP
  module Toolkit
    module Buddhi
      module Profiles

        # Simple profile defintion
        # 1 account
        # # 1 applications
        #
        # 1 product
        # # 1 Application plan per product
        # # 1 application plan limits per product
        # # 1 backends used per product
        # # 1 Method per product
        # # 1 MappingRule per product
        #
        # 1 backend
        # # 0 Method per backend
        # # 0 MappingRule per backend
        class Simple
          def self.call(portal, endpoint)
            client = ThreeScale.client(portal)
            service = ThreeScale::Helper.create_service(client)
            plan = ThreeScale::Helper.create_application_plan(client, service)
            hits_metric_obj = ThreeScale::Helper.hits_metric(client, service)
            ThreeScale::Helper.create_application_plan_limit(client, service, plan, hits_metric_obj.fetch('id'))
            ThreeScale::Helper.delete_mapping_rules(client, service)
            ThreeScale::Helper.create_mapping_rule(client, service, '/pets')
            account = ThreeScale::Helper.account(client)
            ThreeScale::Helper.create_application(client, plan, account)
            begin
              backend = ThreeScale::Helper.create_backend(client, endpoint)
              ThreeScale::Helper.create_backend_usage(client, service, backend, '/')
            rescue ::ThreeScale::API::HttpClient::ForbiddenError, ::ThreeScale::API::HttpClient::NotFoundError
              # 3scale Backends not supported
              ThreeScale::Helper.update_private_endpoint(client, service, endpoint)
            end
            ThreeScale::Helper.bump_proxy_conf(client, service)
            ThreeScale::Helper.promote_proxy_conf(client, service)
            return [service.fetch('id')]
          end
        end

        Register.register_profile(:simple) { |portal, endpoint| Simple.call(portal, endpoint) }
      end
    end
  end
end
