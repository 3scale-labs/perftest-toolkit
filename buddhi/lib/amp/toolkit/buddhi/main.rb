module AMP
  module Toolkit
    module Buddhi
      def self.main
        opts = Buddhi::CLI.run

        unless opts.fetch(:profile).nil?
          service_id_list = Profiles::Register.call opts
          opts[:services] = service_id_list.join(',')
        end

        Buddhi::Factory.call opts
      end
    end
  end
end
