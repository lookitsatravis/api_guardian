# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json
      JSON.parse(response.body)
    end
  end

  module AuthHelpers
    def custom_headers
      @custom_headers ||= {
        'Content-Type' => 'application/vnd.api+json',
        'Accept' => 'application/vnd.api+json'
      }
    end

    def current_user
      @current_user ||= create(:user)
    end

    def seed_permissions(resource)
      %w(create read update delete manage).each do |p|
        create(:permission, name: "#{resource}:#{p}")
        current_user.role.add_permission("#{resource}:#{p}")
      end
    end

    def auth_user
      user = current_user
      access_token = Doorkeeper::AccessToken.create!(resource_owner_id: user.id, expires_in: 7200)
      add_header('Authorization', "Bearer #{access_token.token}")
      user
    end

    def destroy_user
      @current_user = nil
      remove_header('Authorization')
    end

    def add_user_permission(perm_name)
      current_user.role.add_permission(perm_name)
    end

    def remove_user_permission(perm_name)
      current_user.role.remove_permission(perm_name)
    end

    def add_header(key, value)
      custom_headers[key] = value
    end

    def remove_header(key)
      custom_headers.delete(key)
    end

    def get_headers
      custom_headers
    end
  end

  module ErrorHelpers
    def validate_unprocessable_entity(detail = '')
      detail = detail.to_json if detail.is_a?(Array) || detail.is_a?(Hash)

      validate_api_error(
        status: 422,
        code: 'unprocessable_entity',
        title: 'Unprocessable Entity',
        detail: detail
      )
    end

    def validate_not_found(url = '')
      validate_api_error(
        status: 404,
        code: 'not_found',
        title: 'Not Found',
        detail: 'Resource or endpoint missing: http://www.example.com' + url
      )
    end

    def validate_api_error(**expected)
      expect(response).to have_content_type('application/json')
      expect(response).to have_http_status(expected[:status])
      expect(error_id.length).to be 36
      expect(error_status).to eq(expected[:status].to_s)
      expect(error_code).to eq expected[:code]
      expect(error_title).to eq expected[:title]
      expect(error_detail).to eq expected[:detail]
    end

    def error_id(index = 0)
      json['errors'][index]['id']
    end

    def error_code(index = 0)
      json['errors'][index]['code']
    end

    def error_status(index = 0)
      json['errors'][index]['status']
    end

    def error_title(index = 0)
      json['errors'][index]['title']
    end

    def error_detail(index = 0)
      detail = json['errors'][index]['detail']
      detail = detail.to_json if detail.is_a?(Array) || detail.is_a?(Hash)
      detail
    end
  end
end
