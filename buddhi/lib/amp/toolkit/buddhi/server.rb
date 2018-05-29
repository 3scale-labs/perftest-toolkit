require 'webrick'

module AMP
  module Toolkit
    module Buddhi
      class Server
        attr_reader :test_plan, :services_info

        def initialize(test_plan)
          @test_plan = test_plan
          @server = WEBrick::HTTPServer.new Port: test_plan.http_port
          @server.mount_proc '/admin/api/services.json', method(:services)
          @server.mount_proc '/admin/api/services/', method(:service)
          @server.mount_proc '/paths/amp', method(:amp_paths)
          @server.mount_proc '/paths/backend', method(:backend_paths)
        end

        def start
          trap 'INT' do @server.shutdown end
          @server.start
        end

        def services(_, res)
          services = test_plan.services.map do |id:, **|
            { service: { id: id } }
          end
          res.body = { services: services }.to_json
        end

        def service(req, res)
          _, service_id, * = req.path_info.split('/')
          service = test_plan.apicast_service_info service_id
          res.body = { proxy_config: { content: service } }.to_json
        end

        def amp_paths(req, res)
          path(req, res, test_plan.method(:amp_path))
        end

        def backend_paths(req, res)
          path(req, res, test_plan.method(:backend_path))
        end

        def path(req, res, test_plan_method)
          num_lines = req.query.fetch('lines', 1).to_i
          res.content_type = 'text/html; charset=utf-8'
          res.body = Array.new(num_lines) { test_plan_method.call }.join("\n")
        end

        def self.run(test_plan)
          new(test_plan).start
        end
      end
    end
  end
end
