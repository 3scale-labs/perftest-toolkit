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
        Register.register_profile(:standard) do |**opts|
          opts[:services_n] = 100
          opts[:app_per_plan_n] = 100
          opts[:backend_per_svc_n] = 10
          opts[:methods_per_backend_n] = 50
          opts[:limits_per_product] = 10

          MultiService.call(**opts)
        end
      end
    end
  end
end
