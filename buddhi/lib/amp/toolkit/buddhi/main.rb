module AMP
  module Toolkit
    module Buddhi
      def self.main
        opts = AMP::Toolkit::Buddhi::CLI.run
        AMP::Toolkit::Buddhi::Factory.call opts
      end
    end
  end
end
