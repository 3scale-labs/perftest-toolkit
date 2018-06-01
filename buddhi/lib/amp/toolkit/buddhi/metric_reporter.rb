require 'csv'

module AMP
  module Toolkit
    module Buddhi
      class MetricReporter
        attr_reader :test_plan
        def initialize(test_plan)
          @test_plan = test_plan
        end

        def report(data)
          CSV.parse(data).map(&method(:parse)).each_with_object({}) do |(service_id, path), hsh|
            hsh.merge!(test_plan.metric_report(service_id, path)) { |_, old, new| old + new }
          end
        end

        private

        def parse(row)
          host, full_path = row.map(&:strip)
          [host.split('.')[0], URI(full_path).path]
        end
      end
    end
  end
end
