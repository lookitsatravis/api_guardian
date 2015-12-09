require 'active_support/concern'

module ApiGuardian
  module Concerns
    module TwilioVoiceOtpHelper
      extend ActiveSupport::Concern

      included do
        skip_before_action :doorkeeper_authorize!, only: [:voice_otp]
        skip_before_action :prep_response, only: [:voice_otp]
        skip_before_action :validate_api_request, only: [:voice_otp]
        skip_before_action :find_and_authorize_resource, only: [:voice_otp]
        skip_after_action :verify_authorized, only: [:voice_otp]

        def voice_otp
          return unless validate_twilio_request
          user = ApiGuardian::Stores::UserStore.new(nil).find(params[:id])
          render xml: otp_response(user)
        end

        private

        def validate_twilio_request
          sig = request.headers['HTTP_X_TWILIO_SIGNATURE'] || ''
          twilio_validator = Twilio::Util::RequestValidator.new(ApiGuardian.configuration.twilio_token)

          unless twilio_validator.validate(request.url, request.request_parameters, sig)
            render xml: hangup_response, status: :unauthorized
            return false
          end

          true
        end

        def otp_response(user)
          otp = generate_otp_text(user.otp_code)
          phrase = "Hello! Your authorization code is #{otp}." \
                   " Once again, your authorization code is #{otp}." \
                   ' Good bye!'

          response = Twilio::TwiML::Response.new do |r|
            r.Say phrase, voice: 'alice'
          end

          response.text
        end

        def hangup_response
          response = Twilio::TwiML::Response.new(&:Hangup)
          response.text
        end

        def generate_otp_text(otp)
          otp.split(//).join(',,')
        end
      end
    end
  end
end
