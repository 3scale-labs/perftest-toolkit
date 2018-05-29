require 'amp/toolkit/buddhi'
require 'pisoni'

RSpec.describe AMP::Toolkit::Buddhi::Backend, 'call' do
  let(:plan) { AMP::Toolkit::Buddhi::Factory.call(testplan: 'onprem') }

  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:faraday) do
    Faraday.new { |b| b.adapter :test, stubs }
  end

  describe '.run' do
    before do
      allow(ThreeScale::Core).to receive(:faraday).and_return(faraday)
      allow(ThreeScale::Core::Service).to receive(:save!)
      allow(ThreeScale::Core::Metric).to receive(:save)
      allow(ThreeScale::Core::Application).to receive(:save)
      allow(ThreeScale::Core::UsageLimit).to receive(:save)
      allow(ThreeScale::Core::Application).to receive(:save_id_by_key)
      allow(ThreeScale::Core::ApplicationKey).to receive(:save)
    end

    it 'creates each defined service' do
      plan.services.each do |service|
        expect(ThreeScale::Core::Service).to receive(:save!).with(service)
      end
      described_class.run(plan)
    end

    it 'creates each defined metric' do
      plan.metrics.each do |metric|
        expect(ThreeScale::Core::Metric).to receive(:save).with(metric)
      end
      described_class.run(plan)
    end

    it 'creates each defined application' do
      plan.applications.each do |app|
        expect(ThreeScale::Core::Application).to receive(:save).with(app)
      end
      described_class.run(plan)
    end

    it 'creates each defined usage_limit' do
      plan.usage_limits.each do |usage_limit|
        expect(ThreeScale::Core::UsageLimit).to receive(:save).with(usage_limit)
      end
      described_class.run(plan)
    end
  end
end
