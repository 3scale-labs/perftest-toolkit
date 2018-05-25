RSpec.describe AMP::Toolkit::Buddhi::CLI, 'run' do
  describe 'happy path' do
    let(:args) { '-I http://internal_api:3000 -B http://backend_api:3000 -p 8000 -U internal_api_user -P internal_api_password -E http://echo-api.3scale.net -T saas -A http://benchmark.3sca.net' }
    subject(:result) { described_class.run(args.split(' ')) }
    it 'arg parsing should be success' do
      is_expected.to match(testplan: 'saas', backend: 'http://backend_api:3000',
                           internal_api: 'http://internal_api:3000',
                           username: 'internal_api_user', password: 'internal_api_password',
                           endpoint: 'http://echo-api.3scale.net', port: 8000,
                           apicast: 'http://benchmark.3sca.net')
    end
  end

  describe 'backend missing' do
    let(:args) { '-I http://internal_api:3000 -p 8000 -U internal_api_user -P internal_api_password -E http://echo-api.3scale.net -T saas -A http://benchmark.3sca.net' }
    it 'arg parsing should fail' do
      expect { described_class.run(args.split(' ')) }.to raise_exception(SystemExit).and output(/missing required option `-B'/).to_stderr
    end
  end

  describe 'username missing' do
    let(:args) { '-I http://internal_api:3000 -B http://backend_api:3000 -p 8000 -P internal_api_password -E http://echo-api.3scale.net -T saas -A http://benchmark.3sca.net' }
    it 'arg parsing should fail' do
      expect { described_class.run(args.split(' ')) }.to raise_exception(SystemExit).and output(/missing required option `-U'/).to_stderr
    end
  end

  describe 'password missing' do
    let(:args) { '-I http://internal_api:3000 -B http://backend_api:3000 -p 8000 -U internal_api_user -E http://echo-api.3scale.net -T saas -A http://benchmark.3sca.net' }
    it 'arg parsing should fail' do
      expect { described_class.run(args.split(' ')) }.to raise_exception(SystemExit).and output(/missing required option `-P'/).to_stderr
    end
  end

  describe 'endpoint missing' do
    let(:args) { '-I http://internal_api:3000 -B http://backend_api:3000 -p 8000 -U internal_api_user -P internal_api_password -T saas -A http://benchmark.3sca.net' }
    it 'arg parsing should fail' do
      expect { described_class.run(args.split(' ')) }.to raise_exception(SystemExit).and output(/missing required option `-E'/).to_stderr
    end
  end
end
