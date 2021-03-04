module AMP
  module Toolkit
    module Buddhi
      module Profiles
        # Medium profile defintion
        # 1 account
        # # 500 applications
        #
        # 10 products
        # # 1 Application plan per product
        # # 10 application plan limits per product
        # # 50 applications under each plan
        # # 5 backends used per product
        #
        # 50 backends
        # # 10 Methods per backend
        # # 10 MappingRules per backend
        Register.register_profile(:medium) do |**opts|
          opts[:services_n] = 10
          opts[:app_per_plan_n] = 50
          opts[:backend_per_svc_n] = 5
          opts[:methods_per_backend_n] = 10
          opts[:limits_per_product] = 10
          MultiService.call(**opts)
        end
      end
    end
  end
end
