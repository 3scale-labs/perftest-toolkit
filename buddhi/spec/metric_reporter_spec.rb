require 'amp/toolkit/buddhi'
RSpec.describe AMP::Toolkit::Buddhi::MetricReporter do
  let(:test_plan) { instance_double(AMP::Toolkit::Buddhi::Simple::TestPlan) }
  subject { described_class.new test_plan }
  describe 'report' do
    it 'should return empty hash when empty input' do
      expect(test_plan).not_to receive(:metric_report)
      expect(subject.report('')).to eq({})
    end

    it 'should return aggregated results' do
      data = %("a533908aa896.benchmark.3sca.net","/1?app_id=4cc&app_key=fcc"
"cb0a88b8da15.benchmark.3sca.net","/1?app_id=74ac&app_key=22"
"a533908aa896.benchmark.3sca.net","/11?app_id=6ba&app_key=ff"
)
      expect(test_plan).to receive(:metric_report).with('a533908aa896', '/1').and_return('base' => 1, 'metric_1' => 3)
      expect(test_plan).to receive(:metric_report).with('cb0a88b8da15', '/1').and_return('base' => 1, 'metric_2' => 2)
      expect(test_plan).to receive(:metric_report).with('a533908aa896', '/11').and_return('base' => 2, 'metric_1' => 3, 'metric_3' => 1)
      expect(subject.report(data)).to eq('base' => 4, 'metric_1' => 6, 'metric_3' => 1, 'metric_2' => 2)
    end
  end
end
