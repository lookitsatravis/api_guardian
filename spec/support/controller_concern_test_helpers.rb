require 'active_support/concern'

module ControllerConcernTestHelpers
  extend ActiveSupport::Concern

  included do
    attr_accessor :action_name

    def request
      ActionDispatch::Request.new 'test'
    end

    def params
      ActionController::Parameters.new(id: 'test')
    end

    def resource_name
      'User'
    end
  end
end
