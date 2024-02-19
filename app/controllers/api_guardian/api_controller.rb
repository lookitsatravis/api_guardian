# frozen_string_literal: true

module ApiGuardian
  class ApiController < ActionController::API
    include ::Pundit
    include ApiGuardian::Concerns::ApiErrors::Handler
    include ApiGuardian::Concerns::ApiRequest::Validator

    before_action :doorkeeper_authorize!
    before_action :set_current_user
    before_action :prep_response
    before_action :validate_api_request
    before_action :find_and_authorize_resource, except: [:index, :new, :create]
    after_action :verify_policy_scoped, only: :index
    after_action :verify_authorized, except: [:index]
    append_before_action :set_current_request

    rescue_from Exception, with: :api_error_handler

    attr_reader :current_user

    def index
      @resources = should_paginate? ?
        resource_store.paginate(page_params[:number], page_params[:size]) :
        resource_store.all
      render json: resource_serializer.new(@resources, options(@resources))
    end

    def show
      render json: resource_serializer.new(@resource, options(@resource))
    end

    def create
      authorize resource_class
      @resource = resource_store.create(create_resource_params)
      render json: resource_serializer.new(@resource, options(@resource)), status: :created
    end

    def update
      @resource = resource_store.update(@resource, update_resource_params)
      render json: resource_serializer.new(@resource, options(@resource))
    end

    def destroy
      @resource.destroy!
      head :no_content
    end

    protected

    def find_and_authorize_resource
      @resource = resource_store.find(params[:id])
      authorize @resource
    end

    def resource_store
      @resource_store ||= find_and_init_store
    end

    def resource_name
      @resource_name ||= controller_name.classify
    end

    def resource_class
      @resource_class ||= find_resource_class
    end

    def resource_policy
      @resource_policy ||= action_name == 'index' ? policy_scope(resource_class) : nil
    end

    def resource_serializer
      @resource_serializer ||= find_and_init_serializer
    end

    # :nocov:
    def includes
      []
    end
    # :nocov:

    def create_resource_params
      params.require(:data).require(:attributes).permit(create_params)
    end

    def update_resource_params
      params.require(:data).require(:attributes).permit(update_params)
    end

    # :nocov:
    def create_params
      []
    end
    # :nocov:

    def page_params
      params.fetch(:page, number: 1, size: 25)
    end

    # :nocov:
    def update_params
      []
    end
    # :nocov:

    def set_policy(new_policy = nil)
      @resource_policy = new_policy
    end

    def should_paginate?
      params[:paginate] != 'false'
    end

    private

    def set_current_user
      @current_user = ApiGuardian.configuration.user_class.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      ApiGuardian.current_user = @current_user
    end

    def prep_response
      response.headers['Content-Type'] = 'application/vnd.api+json'
    end

    def set_current_request
      ApiGuardian.current_request = request
    end

    def find_and_init_store
      store = nil

      # Check for app-specific store
      if ApiGuardian.class_exists?(resource_name + 'Store')
        store = resource_name + 'Store'
      end

      # Check for ApiGuardian Store
      unless store
        if ApiGuardian.class_exists?('ApiGuardian::Stores::' + resource_name + 'Store')
          store = 'ApiGuardian::Stores::' + resource_name + 'Store'
        end
      end

      return store.constantize.new(resource_policy) if store

      fail ApiGuardian::Errors::ResourceStoreMissing, 'Could not find a resource store ' \
           "for #{resource_name}. Have you created one? You can override `#resource_store` " \
           'in your controller in order to set it up specifically.'
    end

    def find_resource_class
      if ApiGuardian.class_exists?(resource_name)
        resource_name.constantize
      elsif ApiGuardian.configuration.respond_to? "#{resource_name.downcase}_class"
        ApiGuardian.configuration.send("#{resource_name.downcase}_class")
      else
        fail ApiGuardian::Errors::ResourceClassMissing, 'Could not find a resource class (model) ' \
             "for #{resource_name}. Have you created one?"
      end
    end

    def find_and_init_serializer
      serializer = nil
      action = action_name&.downcase&.upcase_first || ''

      # Check for app-specific serializer
      if ApiGuardian.class_exists?(resource_name + action + 'Serializer')
        serializer = resource_name + action + 'Serializer'
      end

      unless serializer
        if ApiGuardian.class_exists?(resource_name + 'Serializer')
          serializer = resource_name + 'Serializer'
        end
      end

      # Check for ApiGuardian serializer
      unless serializer
        if ApiGuardian.class_exists?('ApiGuardian::' + resource_name + 'Serializer')
          serializer = 'ApiGuardian::' + resource_name + 'Serializer'
        end
      end

      return serializer.constantize if serializer

      fail ApiGuardian::Errors::ResourceSerializerMissing, 'Could not find a resource serializer ' \
           "for #{resource_name}. Have you created #{resource_name}Serializer?"
    end

    def options(resources)
      options = {}
      options[:include] = includes if includes.count.positive?
      links = resource_links(resources)
      options[:links] = resource_links(resources) if links

      options
    end

    def resource_links(resources)
      return nil unless resources.respond_to?(:next_page)

      url = "#{request.original_url.split('?')[0]}?page%%5Bnumber%%5D=%i&page%%5Bsize%%5D=#{resources.limit_value}"

      {
        self: url % [resources.current_page],
        first: url % [1],
        prev: resources.length.zero? || resources.first_page? ? nil : url % [resources.prev_page],
        next: resources.length.zero? || resources.last_page? ? nil : url % [resources.next_page],
        last: url % [resources.total_pages],
      }
    end
  end
end
