require 'amp/toolkit/buddhi'

RSpec.describe AMP::Toolkit::Buddhi::Factory do
  context 'base factory' do
    let(:options) { { attribA: 1, attribB: 2 } }
    let(:generatorA) { double('generatorA') }

    before do
      described_class.register_generator(:generatorA, generatorA)
    end

    it 'call testplan A' do
      expect(generatorA).to receive(:call).with(options)
      # no need to test calling with not registered testplan
      described_class.call(testplan: :generatorA.to_s, **options)
    end

    it 'test generator keys' do
      expect(described_class.generator_keys).to include(:generatorA)
      expect(described_class.generator_keys).not_to include(:generatorC)
    end

    it 'test predefinded keys exist' do
      expect(described_class.generator_keys).to include(:simple)
      expect(described_class.generator_keys).to include(:onprem)
      expect(described_class.generator_keys).to include(:saas)
    end
  end

  context 'simple factory' do
    subject { AMP::Toolkit::Buddhi::Simple::SimpleFactory.new }

    it 'number usage limits does not exceed limit' do
      expect(subject).to receive(:generate).with(max_num_usage_limit(6))
      subject.call
    end
  end

  context 'onprem factory' do
    subject { AMP::Toolkit::Buddhi::OnPremises::OnPremFactory.new }

    it 'number usage limits does not exceed limit' do
      expect(subject).to receive(:generate).with(max_num_usage_limit(6))
      subject.call
    end
  end

  context 'saas factory' do
    subject { AMP::Toolkit::Buddhi::Saas::SaaSFactory.new }

    it 'number usage limits does not exceed limit' do
      expect(subject).to receive(:generate).with(max_num_usage_limit(6))
      subject.call
    end
  end
end
