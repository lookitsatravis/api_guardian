module ApiGuardian
  class Configuration
    class ConfigurationError < RuntimeError
    end

    attr_writer :user_class, :role_class, :permission_class, :role_permission_class,
                :minimum_password_length

    def user_class
      klass = @user_class ||= 'ApiGuardian::User'
      klass.constantize
    end

    def role_class
      klass = @role_class ||= 'ApiGuardian::Role'
      klass.constantize
    end

    def permission_class
      klass = @permission_class ||= 'ApiGuardian::Permission'
      klass.constantize
    end

    def role_permission_class
      klass = @role_permission_class ||= 'ApiGuardian::RolePermission'
      klass.constantize
    end

    def minimum_password_length
      @minimum_password_length ||= 8
    end

    # Example validating configuration
    # def configurable_service
    #   @configurable_service ||= default_configuration_service
    # end
    #
    # def configurable_service=(callable)
    #   if callable.respond_to?(:call)
    #     @configurable_service = callable
    #   else
    #     raise ConfigurationError.new("Expected #{callable.inspect} to respond_to #call. Could not set #{self.class}#configurable_service.")
    #   end
    # end
    #
    # private
    # def default_configuration_service
    #   lambda {|args| ... }
    # end
  end
end
