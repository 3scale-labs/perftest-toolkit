module AMP
  module Toolkit
    module Buddhi
      module Profiles
        class Register
          @profiles = {}
          def self.register_profile(key, profile)
            @profiles[key] = profile
          end

          def self.profile_keys
            @profiles.keys
          end

          def self.call(profile:, portal:, **options)
            # profile is a valid
            @profiles[profile.to_sym].call(ThreeScale.client(portal), options)
          end
        end
      end
    end
  end
end
