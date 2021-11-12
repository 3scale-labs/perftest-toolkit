module AMP
  module Toolkit
    module Buddhi
      def self.main
        opts = Buddhi::CLI.run

        unless opts.fetch(:profile).nil?
          service_id_list = Profiles::Register.call **opts
          opts[:services] = service_id_list.join(',')
        end

        puts "================== provisioning done, reading services"

        Buddhi::Factory.call **opts
      end
    end
  end
end
