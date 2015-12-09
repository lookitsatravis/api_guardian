module Test
  class Dummy
    include ControllerConcernTestHelpers
    include ApiGuardian::Concerns::TwilioVoiceOtpHelper
  end
end

describe ApiGuardian::Concerns::TwilioVoiceOtpHelper, type: :request do
  let(:dummy_class) { Test::Dummy.new }

  context 'filters' do
    it 'should skip irrelevant before actions' do
      # The following doesn't work for some reason.
      # expect(dummy_class.class).to receive(:skip_before_action).with(
      #   :doorkeeper_authorize!, only: [:voice_otp]
      # )

      expect(dummy_class.class.skip_befores).to include(
        name: :doorkeeper_authorize!, contraints: { only: [:voice_otp] }
      )

      expect(dummy_class.class.skip_befores).to include(
        name: :prep_response, contraints: { only: [:voice_otp] }
      )

      expect(dummy_class.class.skip_befores).to include(
        name: :validate_api_request, contraints: { only: [:voice_otp] }
      )

      expect(dummy_class.class.skip_befores).to include(
        name: :find_and_authorize_resource, contraints: { only: [:voice_otp] }
      )
    end

    it 'should skip irrelevant after actions' do
      expect(dummy_class.class.skip_afters).to include(
        name: :verify_authorized, contraints: { only: [:voice_otp] }
      )
    end
  end

  # Methods
  describe 'methods' do
    before(:each) do
      allow_any_instance_of(ActionDispatch::Http::Headers).to receive(:[]).and_return('test')
      allow_any_instance_of(ActionDispatch::Request).to receive(:headers).and_return(mock_headers)
      allow_any_instance_of(ActionDispatch::Request).to receive(:url).and_return('http://example.com')
      allow_any_instance_of(ActionDispatch::Request).to receive(:request_parameters).and_return({})
      allow_any_instance_of(ApiGuardian::Configuration).to receive(:twilio_token).and_return('ABC')
    end

    let(:mock_headers) { ActionDispatch::Http::Headers.new }

    describe '#voice_otp' do
      it 'fails if twilio validator fails' do
        expect_any_instance_of(Twilio::Util::RequestValidator).to(
          receive(:validate).with('http://example.com', {}, 'test').and_return(false)
        )

        expect(dummy_class).to receive(:render).with(
          xml: '<?xml version="1.0" encoding="UTF-8"?><Response><Hangup/></Response>',
          status: :unauthorized
        )

        dummy_class.voice_otp
      end

      it 'renders proper Twiml XML when validated' do
        user = mock_model(ApiGuardian::User)
        expect_any_instance_of(Twilio::Util::RequestValidator).to receive(:validate).and_return true
        expect(ApiGuardian::User).to receive(:find).and_return user
        expect(user).to receive(:otp_code).and_return('000')

        expect(dummy_class).to receive(:render).with(
          xml: '<?xml version="1.0" encoding="UTF-8"?><Response><Say voice="alice">' \
               'Hello! Your authorization code is 0,,0,,0. Once again, your authorization' \
               ' code is 0,,0,,0. Good bye!</Say></Response>'
        )

        dummy_class.voice_otp
      end
    end
  end
end
