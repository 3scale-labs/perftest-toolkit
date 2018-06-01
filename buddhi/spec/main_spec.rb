require 'amp/toolkit/buddhi'

RSpec.describe AMP::Toolkit::Buddhi do
  let(:opts) { { testplan: 'some_plan' } }
  let(:test_plan) { { test_plan: 1 } }
  let(:metric_reporter) { {} }

  before do
    expect(AMP::Toolkit::Buddhi::CLI).to receive(:run).and_return(opts)
    expect(AMP::Toolkit::Buddhi::Factory).to receive(:call).with(opts).and_return(test_plan)
    expect(AMP::Toolkit::Buddhi::MetricReporter).to receive(:new).with(test_plan).and_return(metric_reporter)
    expect(AMP::Toolkit::Buddhi::Backend).to receive(:run).with(test_plan)
    expect(AMP::Toolkit::Buddhi::Server).to receive(:run).with(test_plan, metric_reporter)
  end

  it 'main' do
    described_class.main
  end
end
