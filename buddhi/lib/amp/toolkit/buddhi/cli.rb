module AMP
  module Toolkit
    module Buddhi
      class CLI
        def self.cli_flags
          options = ::Slop::Options.new
          options.banner = 'usage: buddhi [options]'
          options.string '-P', '--portal', 'Admin portal endpoint', required: true do |portal|
            raise Slop::Error, 'admin portal not valid' unless Factory.validate_portal portal
          end
          options.string '-s', '--services', '3scale service list', required: true
          options.string '-o', '--output', 'output file', required: true

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
