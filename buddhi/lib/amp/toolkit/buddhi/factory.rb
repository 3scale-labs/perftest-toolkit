require 'securerandom'

module AMP
  module Toolkit
    module Buddhi
      class Factory
        @generators = {}
        def self.register_generator(key, generator)
          @generators[key] = generator
        end

        def self.generator_keys
          @generators.keys
        end

        def self.call(testplan:, **options)
          # testplan is a valid generator key
          @generators[testplan.to_sym].call(options)
        end
      end
    end
  end
end
