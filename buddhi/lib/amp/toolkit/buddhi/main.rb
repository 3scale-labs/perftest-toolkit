module AMP
  module Toolkit
    module Buddhi
      def self.main
        opts = AMP::Toolkit::Buddhi::CLI.run
        test_plan = AMP::Toolkit::Buddhi::Factory.call opts
        AMP::Toolkit::Buddhi::Backend.run test_plan
        AMP::Toolkit::Buddhi::Server.run test_plan
      end
    end
  end
end
