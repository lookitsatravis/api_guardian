# frozen_string_literal: true

module ApiGuardian
  module Serializers
    class Base
      include FastJsonapi::ObjectSerializer
      set_key_transform ApiGuardian.configuration.json_api_key_transform
    end
  end
end
