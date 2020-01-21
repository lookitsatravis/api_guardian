# frozen_string_literal: true

require 'active_support/concern'

module ControllerConcernTestHelpers
  extend ActiveSupport::Concern

  included do
    class << self
      attr_accessor :skip_befores, :skip_afters
    end

    attr_accessor :action_name

    def self.skip_before_action(name, contraints)
      @skip_befores = [] unless @skip_befores.is_a? Array
      @skip_befores.push(name: name, contraints: contraints)
    end

    def self.skip_after_action(name, contraints)
      @skip_afters = [] unless @skip_afters.is_a? Array
      @skip_afters.push(name: name, contraints: contraints)
    end

    def render(options)
    end

    def request
      ActionDispatch::Request.new 'test'
    end

    def params
      ActionController::Parameters.new(id: 'test')
    end

    def resource_name
      @resource_name || 'User'
    end

    def resource_name=(value)
      @resource_name = value.to_s
    end
  end
end
