require 'amp/toolkit/buddhi'
require 'set'

RSpec.describe 'Generator' do
  let(:generator) { Class.new { include AMP::Toolkit::Buddhi::Generator }.new }
  let(:n_providers) { 10 }
  let(:n_services) { 3 }
  let(:n_metrics) { 4 }
  let(:n_apps) { 5 }
  let(:n_plans) { 6 }
  let(:n_usage_limits) { 2 }

  subject do
    generator.generate(n_providers: n_providers,
                       n_services: n_services,
                       n_metrics: n_metrics,
                       n_apps: n_apps,
                       n_plans: n_plans,
                       n_usage_limits: n_usage_limits)
  end

  let(:service) { subject.values.first }

  it { should_not be_empty }

  context 'services' do
    it 'expected number of keys' do
      expect(subject.keys.size).to eq(n_services * n_providers)
    end

    it 'all providers are included' do
      provider_set = subject.values.each_with_object(Set.new) do |service, acc|
        acc.add(service[:provider_key])
      end
      expect(provider_set.size).to eq(n_providers)
    end
  end

  context 'one service' do
    it 'contains expected attributes' do
      %i[id backend_version provider_key].each do |key|
        expect(service.keys).to include(key)
        expect(service[key]).not_to be_empty
      end
    end
  end

  context 'metrics' do
    it 'contains metric key' do
      expect(service.keys).to include(:metrics)
      expect(service[:metrics]).not_to be_empty
    end

    it 'expected number of metrics' do
      expect(service[:metrics].keys.size).to eq(n_metrics + 1)
    end

    it 'contains expected attributes' do
      metric = service[:metrics].values.first
      %i[service_id service id name].each do |key|
        expect(metric.keys).to include(key)
        expect(metric[key]).not_to be_empty
      end
      expect(metric.keys).to include(:parent_id)
    end

    it 'parent metric is hits' do
      hits_metric = service[:metrics].values.select { |metric| metric[:parent_id].nil? }
      expect(hits_metric.size).to eq(1)
      method_metric = service[:metrics].values.reject { |metric| metric[:parent_id].nil? }
      expect(method_metric.size).to be > 0
      method_metric.each do |metric|
        expect(metric[:parent_id]).to eq(hits_metric[0][:id])
      end
    end
  end

  context 'plans' do
    it 'contains plans key' do
      expect(service.keys).to include(:plans)
      expect(service[:plans]).not_to be_empty
    end

    it 'expected number of plans' do
      expect(service[:plans].keys.size).to eq(n_plans)
    end

    it 'contains expected attributes' do
      plan = service[:plans].values.first
      %i[service_id service id name].each do |key|
        expect(plan.keys).to include(key)
        expect(plan[key]).not_to be_empty
      end
    end
  end

  context 'applications' do
    it 'contains applications key' do
      expect(service.keys).to include(:applications)
      expect(service[:applications]).not_to be_empty
    end

    it 'expected number of applications' do
      expect(service[:applications].keys.size).to eq(n_apps)
    end

    it 'contains expected attributes' do
      application = service[:applications].values.first
      %i[service_id service id state plan plan_id plan_name keys].each do |key|
        expect(application.keys).to include(key)
        expect(application[key]).not_to be_empty
      end
    end
  end

  context 'application keys' do
    let(:application) { service[:applications].values.first }

    it 'contains expected number' do
      expect(application[:keys].size).to eq(1)
    end

    it 'contains expected attributes' do
      application_key = application[:keys].first
      %i[application application_id service service_id].each do |key|
        expect(application_key.keys).to include(key)
        expect(application_key[key]).not_to be_empty
      end
      expect(application_key.keys).to include(:user_key).or(include(:value))
    end
  end

  context 'usage_limits' do
    it 'contains usage_limits key' do
      expect(service.keys).to include(:usage_limits)
      expect(service[:usage_limits]).not_to be_empty
    end

    it 'contains expected number' do
      expect(service[:usage_limits].size).to eq(n_usage_limits * (n_metrics + 1) * n_plans)
    end

    it 'contains expected attributes' do
      usage_limit = service[:usage_limits].first
      %i[service_id metric_id plan_id].each do |key|
        expect(usage_limit.keys).to include(key)
        expect(usage_limit[key]).not_to be_empty
      end
      expect(usage_limit.keys).to include(:hour).or(include(:day)).or(include(:week)).or(include(:month)).or(include(:year)).or(include(:eternity))
    end
  end
end
