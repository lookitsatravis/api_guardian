require 'koala'

module ApiGuardian
  module Helpers
    class Facebook
      attr_reader :access_token

      def initialize(access_token)
        @access_token = access_token
      end

      def authorize!
        graph = Koala::Facebook::API.new(@access_token)
        graph.get_object('me', fields: 'id,name,email')
      rescue Koala::KoalaError => e
        ApiGuardian.logger.error "Facebook authorization failed! #{e.message}"
        fail ApiGuardian::Errors::IdentityAuthorizationFailed, "Could not connect to Facebook: #{e.message}"
      end
    end
  end
end
