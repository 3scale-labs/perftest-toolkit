module AMP
  module Toolkit
    module Buddhi
      def self.main
        opts = AMP::Toolkit::Buddhi::CLI.run
        test_plan = AMP::Toolkit::Buddhi::Factory.call opts
        metric_report = AMP::Toolkit::Buddhi::MetricReporter.new test_plan
        AMP::Toolkit::Buddhi::Backend.run test_plan
        AMP::Toolkit::Buddhi::Server.run test_plan, metric_report
      end
    end
  end
end
