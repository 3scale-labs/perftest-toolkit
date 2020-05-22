module AMP
  module Toolkit
    module Buddhi
      module Profiles
        class Register
          @profiles = {}
          def self.register_profile(key, &block)
            @profiles[key] = block
          end

          def self.profile_keys
            @profiles.keys
          end

          def self.call(profile:, portal:, endpoint:, **_options)
            # profile is a valid
            @profiles[profile.to_sym].call(portal, endpoint)
          end
        end
      end
    end
  end
end
