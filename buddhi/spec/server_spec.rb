require 'amp/toolkit/buddhi'

RSpec.describe AMP::Toolkit::Buddhi::Server do
  let(:test_plan) { instance_double(AMP::Toolkit::Buddhi::Simple::TestPlan) }
  let(:metric_reporter) { instance_double(AMP::Toolkit::Buddhi::MetricReporter) }

  context 'bootstrap' do
    let(:server) { instance_double(WEBrick::HTTPServer) }

    before do
      expect(test_plan).to receive(:http_port).and_return(80)
      expect(server).to receive(:mount_proc).with('/admin/api/services.json', anything)
      expect(server).to receive(:mount_proc).with('/admin/api/services/', anything)
      expect(server).to receive(:mount_proc).with('/paths/amp', anything)
      expect(server).to receive(:mount_proc).with('/paths/backend', anything)
      expect(server).to receive(:mount_proc).with('/report/amp', anything)
      expect(server).to receive(:start)
      expect(WEBrick::HTTPServer).to receive(:new).with(Port: 80).and_return(server)
    end

    it 'run' do
      AMP::Toolkit::Buddhi::Server.run test_plan, metric_reporter
    end
  end

  context 'api endpoints' do
    let(:resp) { WEBrick::HTTPResponse.new WEBrick::Config::HTTP }
    let(:server) { described_class.new test_plan, metric_reporter }
    let(:services) { [{ id: 'svcA' }, { id: 'svcA' }] }
    let(:service) { { id: 'svc_a' } }

    it 'services method returns list of services' do
      expect(test_plan).to receive(:http_port).and_return(6660)
      expect(test_plan).to receive(:services).and_return(services)
      req = server_build_request '/admin/api/services.json'
      server.services(req, resp)
      # Check returned services are expected ones
      expect(resp.body).to be
      parsed_response = JSON.parse(resp.body)
      expect(parsed_response['services'].size).to eq(2)
      ids = parsed_response['services'].map { |svc| svc['service']['id'] }
      expect(ids).to eq(services.map { |svc| svc[:id] })
    end

    it 'service method returns service metadata info' do
      expect(test_plan).to receive(:http_port).and_return(6661)
      expect(test_plan).to receive(:apicast_service_info).with('svc_a').and_return(service)
      # actual request should be
      # /admin/api/services/svc_a
      # api endpoint is mounted on /admin/api/services
      # req.path_info is based on /svc_a
      req = server_build_request '/svc_a'
      server.service(req, resp)
      # Check returned service info is expected one
      parsed_response = JSON.parse(resp.body)
      expect(parsed_response).to have_key('proxy_config')
      expect(parsed_response['proxy_config']).to have_key('content')
      processed_service = service.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v }
      expect(parsed_response['proxy_config']['content']).to eq(processed_service)
    end

    it 'amp_paths method returns host and path as csv format' do
      expect(test_plan).to receive(:http_port).and_return(6662)
      expect(test_plan).to receive(:amp_path).exactly(5).times.and_return('"some_host", "/some_path"')
      req = server_build_request '/?lines=5'
      server.amp_paths(req, resp)
      # Check response body is several lines as csv format
      expect(resp.body.lines.count).to eq(5)
      expect(resp.body.lines[0].strip).to eq('"some_host", "/some_path"')
    end

    it 'backend_paths method returns backend paths' do
      expect(test_plan).to receive(:http_port).and_return(6663)
      expect(test_plan).to receive(:backend_path).exactly(3).times.and_return('"/some_path"')
      req = server_build_request '/?lines=3'
      server.backend_paths(req, resp)
      # Check response body is several lines of paths
      expect(resp.body.lines.count).to eq(3)
      expect(resp.body.lines[0].strip).to eq('"/some_path"')
    end
  end
end
