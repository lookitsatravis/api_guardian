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

    def validate_password_score
      @validate_password_score ||= true
    end

    def validate_password_score=(value)
      fail ConfigurationError.new('validate_password_score must be a boolean!') unless [true, false].include? value
      @validate_password_score = value
    end

    def minimum_password_score
      @minimum_password_score ||= 4
    end

    def minimum_password_score=(score)
      if (0..4).include?(score)
        if score < 3
          ::Rails.logger.warn '[ApiGuardian] A password score of less than 3 is not recommended.'
        end
        @minimum_password_score = score
      else
        fail ConfigurationError.new('The minimum_password_score must be an integer and between 0..4')
      end
    end
  end
end
