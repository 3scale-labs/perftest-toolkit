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

          def self.call(profile:, portal:, private_base_url:, public_base_url:, **_options)
            public_base_url = nil if !public_base_url.nil? && public_base_url.empty?
            # profile is a valid
            @profiles[profile.to_sym].call(portal, private_base_url, public_base_url)
          end
        end
      end
    end
  end
end
