require 'amp/toolkit/buddhi'

RSpec.describe AMP::Toolkit::Buddhi::TestPlan do
  let(:opts) do
    {
      internal_api: 'my_internal_api',
      backend: 'http://my_backend.io',
      username: 'my_username',
      password: 'my_password',
      port: 7865,
      endpoint: 'my_endpoint',
      apicast: 'http://my_apicast.io'
    }
  end

  context 'common test plan' do
    let(:services) do
      {
        svc_a: {
          id: 'idA',
          backend_version: 2,
          provider_key: 'some_prov_key_a',
          metrics: {
            m_a_1: {
              name: 'm_a_1'
            },
            m_a_2: {
              name: 'm_a_2'
            }
          },
          application_keys: [{ user_key: 'key_a' }],
          unexpected_arg_a: 'unexpected_value_a'
        },
        svc_b: {
          id: 'idB',
          backend_version: 2,
          provider_key: 'some_prov_key_b',
          metrics: {
            m_b_1: {
              name: 'm_b_1'
            },
            m_b_2: {
              name: 'm_b_2'
            }
          },
          application_keys: [{ user_key: 'key_b' }],
          unexpected_arg_b: 'unexpected_value_b'
        }
      }
    end
    subject { AMP::Toolkit::Buddhi::Simple::TestPlan.new(services, opts) }

    it 'internal_backend should be captured' do
      expect(subject.internal_backend).to eq(opts[:internal_api])
    end
    it 'backend_url should be captured' do
      expect(subject.backend_url).to eq(opts[:backend])
    end
    it 'backend_username should be captured' do
      expect(subject.backend_username).to eq(opts[:username])
    end
    it 'backend_password should be captured' do
      expect(subject.backend_password).to eq(opts[:password])
    end
    it 'http_port should be captured' do
      expect(subject.http_port).to eq(opts[:port])
    end

    it 'services attribute should be filtered list of provisioned services' do
      res = subject.services
      expect(res).to be_instance_of(Array)
      expect(res.size).to eq(2)
      res.each do |service|
        expect(service.keys).to contain_exactly(:id, :backend_version, :provider_key)
      end
    end
  end

  context 'simple test plan' do
    let(:services) do
      {
        svc_a: {
          id: 'idA',
          backend_version: 1,
          provider_key: 'some_prov_key_a',
          metrics: {
            m_a_1: {
              name: 'm_a_1'
            },
            m_a_2: {
              name: 'm_a_2'
            }
          },
          application_keys: [{ user_key: 'key_a' }],
          unexpected_arg_a: 'unexpected_value_a'
        }
      }
    end

    subject { AMP::Toolkit::Buddhi::Simple::TestPlan.new(services, opts) }

    it 'apicast_service_info nil when key does not exist' do
      expect(subject.apicast_service_info('unknown key')).to be_nil
    end

    it 'apicast_service_info with expected metadata info' do
      expect(subject.apicast_service_info(:svc_a)).to eq(
        id: 'idA',
        backend_authentication_type: 'provider_key',
        backend_authentication_value: 'some_prov_key_a',
        backend_version: 1,
        proxy: {
          api_backend: 'my_endpoint',
          hosts: ['idA.my_apicast.io'],
          backend: {
            endpoint: 'http://my_backend.io'
          },
          # first metric is the parent 'hits'
          proxy_rules: [
            {
              http_method: 'GET',
              pattern: '/m_a_2/',
              metric_system_name: 'm_a_2',
              delta: 1
            }
          ]
        }
      )
    end

    it 'amp_path should return host and gateway path' do
      expect(subject.amp_path).to eq('"idA.my_apicast.io","/m_a_2/some-request?user_key=key_a"')
    end

    it 'backend_path should return backend path' do
      expect(subject.backend_path).to eq('/transactions/authrep.xml?provider_key=some_prov_key_a&service_id=idA&user_key=key_a&usage%5Bm_a_2%5D=1')
    end
  end

  context 'saas test plan' do
    # saas test plan uses many 'sample' random calls, regexp matching instead
    let(:services) do
      {
        svc_a: {
          id: 'idA',
          backend_version: 1,
          provider_key: 'some_prov_key_a',
          metrics: {
            m_a_1: {
              name: 'm_a_1'
            },
            m_a_2: {
              name: 'm_a_2'
            },
            m_a_3: {
              name: 'm_a_3'
            },
            m_a_4: {
              name: 'm_a_4'
            }
          },
          application_keys: [{ user_key: 'key_a' }],
          unexpected_arg_a: 'unexpected_value_a'
        },
        svc_b: {
          id: 'idB',
          backend_version: 1,
          provider_key: 'some_prov_key_b',
          metrics: {
            m_b_1: {
              name: 'm_b_1'
            },
            m_b_2: {
              name: 'm_b_2'
            },
            m_b_3: {
              name: 'm_b_3'
            },
            m_b_4: {
              name: 'm_b_4'
            }
          },
          application_keys: [{ user_key: 'key_b' }],
          unexpected_arg_b: 'unexpected_value_b'
        }
      }
    end

    subject { AMP::Toolkit::Buddhi::Saas::TestPlan.new(services, opts) }

    it 'apicast_service_info nil when key does not exist' do
      expect(subject.apicast_service_info('unknown key')).to be_nil
    end

    it 'apicast_service_info with expected metadata info' do
      res = subject.apicast_service_info(:svc_b)
      expect(res[:id]).to eq('idB')
      proxy_rules = res[:proxy][:proxy_rules]
      expect(proxy_rules.size).to eq(3)
      expect(proxy_rules[0][:pattern]).to eq('/1')
      expect(proxy_rules[1][:pattern]).to eq('/11')
      expect(proxy_rules[2][:pattern]).to eq('/111')
    end

    it 'amp_path should return host and gateway path' do
      amp_path = subject.amp_path
      amp_parts = amp_path.split(',')
      expect(amp_parts.size).to eq(2)
      expect(amp_parts[0]).to eq('"idA.my_apicast.io"').or eq('"idB.my_apicast.io"')
      expect(amp_parts[1].delete('"')).to match(/\/1+\?user_key=key_[ab]/)
    end

    it 'backend_path should return backend path' do
      expect(subject.backend_path).to match(/\/transactions\/authrep.xml\?provider_key=some_prov_key_[ab]&service_id=id[AB]&user_key=key_[ab](&usage%5Bm_[ab]_1%5D=1)*/)
    end
  end
end
