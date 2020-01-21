# frozen_string_literal: true

module ApiGuardian
  module Errors
    class Error < StandardError
    end

    class IdentityAuthorizationFailed < Error; end
    class InvalidContentType < Error; end
    class InvalidJwtSecret < Error; end
    class InvalidPermissionName < Error; end
    class InvalidAuthenticationProvider < Error; end
    class InvalidRegistrationProvider < Error; end
    class InvalidRequestBody < Error; end
    class InvalidRequestResourceId < Error; end
    class InvalidRequestResourceType < Error; end
    class InvalidUpdateAction < Error; end
    class PasswordInvalid < Error; end
    class PasswordRequired < Error; end
    class PhoneNumberInvalid < Error; end
    class RegistrationValidationFailed < Error; end
    class ResetTokenExpired < Error; end
    class ResetTokenUserMismatch < Error; end
    class TwoFactorRequired < Error; end
    class UserInactive < Error; end
    class ResourceStoreMissing < Error; end
    class ResourceClassMissing < Error; end
    class ResourceSerializerMissing < Error; end
    class GuestAuthenticationDisabled < Error; end
  end
end
