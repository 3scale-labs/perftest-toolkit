module AMP
  module Toolkit
    module Buddhi
      class CLI
        def self.cli_flags
          options = ::Slop::Options.new
          options.banner = 'usage: buddhi [options]'
          options.string '-P', '--portal', 'Admin portal endpoint', required: true
          options.string '-s', '--services', '3scale service list'
          options.string '-e', '--private-base-url', 'Private base URL'
          options.string '-b', '--public-base-url', 'Public base URL'
          options.string '-p', '--profile', "3scale product profile. Valid profiles #{Profiles::Register.profile_keys.map(&:to_s)}" do |profile|
            unless Profiles::Register.profile_keys.include? profile.to_sym
              raise Slop::Error, "Invalid profile: #{profile}"
            end
          end
          options.string '-o', '--output', 'output file', required: true

          options.on '-h', '--help' do
            help!(options)
          end

          options.on '-v', '--version', 'print the version' do
              puts Buddhi::VERSION
              exit
          end

          options
        end

        def self.run(args = ARGV)
          parser = ::Slop::Parser.new cli_flags
          begin
            result = parser.parse(args)
            result.to_hash.tap { |pargs| validate_args(pargs) }
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

        def self.validate_args(pargs)
           raise Slop::Error, 'services or profile parameter is required' if pargs.fetch(:services).nil? && pargs.fetch(:profile).nil?

           raise Slop::Error, 'services and profile parameters are mutually exclusive' unless pargs.fetch(:services).nil? || pargs.fetch(:profile).nil?

           raise Slop::Error, 'admin portal not valid' unless Factory.validate_portal pargs.fetch(:portal)

           # if profile specified, private-base-url is required
           raise Slop::Error, 'private-base-url is required' if !pargs.fetch(:profile).nil? && pargs.fetch(:private_base_url).nil?
        end
      end
    end
  end
end
