require 'slop'

module AMP
  module Toolkit
    module Buddhi
      class CLI
        def self.cli_flags
          options = ::Slop::Options.new
          options.banner = 'usage: buddhi [options]'
          options.string '-T', '--testplan', "load test definition key: #{Factory.generator_keys.map(&:to_s)}", required: true do |testplan|
            unless Factory.generator_keys.include? testplan.to_sym
              raise Slop::Error, "Expected testplans are: #{Factory.generator_keys}"
            end
          end
          options.string '-I', '--internal-api', 'backend internal epi endpoint'
          options.string '-B', '--backend', 'backend endpoint for apicast', required: true
          options.string '-U', '--username', 'backend internal api user', required: true
          options.string '-P', '--password', 'backend internal api password', required: true
          options.string '-E', '--endpoint', 'API upstream endpoint', required: true
          options.string '-A', '--apicast', 'APIcast wildcard domain'
          options.integer '-p', '--port', 'listen port', default: 8089

          options.on '-h', '--help' do
            help!(options)
          end

          options
        end

        def self.run(args = ARGV)
          parser = ::Slop::Parser.new cli_flags
          begin
            result = parser.parse(args)
            result.to_hash
          rescue Slop::Error => error
            error!(error, cli_flags)
          end
        end

        def self.error!(error, options)
          warn "ERROR: #{error.message}"
          warn
          warn options
          exit 1
        end

        def self.help!(options)
          puts options
          exit
        end
      end
    end
  end
end
