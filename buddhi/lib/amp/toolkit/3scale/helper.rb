module AMP
  module Toolkit
    module ThreeScale
      module Helper
        def self.parse_uri(uri)
          # raises error when remote_str is not string, but object or something else.
          uri_obj = URI(uri)
          # URI::HTTP is parent of URI::HTTPS
          # with single check both types are checked
          raise "invalid url: #{uri}" unless uri_obj.kind_of?(URI::HTTP)

          uri_obj
        end
      end
    end
  end
end
