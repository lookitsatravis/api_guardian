# frozen_string_literal: true

describe ApiGuardian::Jobs::SendOtp do
  # Methods
  describe 'methods' do
    describe '#perform' do
      it 'with otp_enabled disabled does nothing' do
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:otp_enabled?).and_return(false)

        subject.perform(user)
      end

      context 'with otp_enabled' do
        let(:user) { mock_model(ApiGuardian::User) }
        let(:to_number) { '18005554321' }
        let(:from_number) { '18885551234' }
        let(:otp_code) { '0101' }

        before(:each) do
          expect(user).to receive(:otp_enabled?).and_return(true)
        end

        context 'can send via SMS' do
          before(:each) do
            expect(user).to receive(:otp_method).and_return('sms')
          end

          it 'executes when forced' do
            my_lambda = lambda { |user| }
            expect_any_instance_of(ApiGuardian::Configuration).to receive(:on_send_otp_via_sms).and_return(my_lambda)
            expect(my_lambda).to receive(:call)

            subject.perform(user, true)
          end

          context 'executes when user can receive SMS' do
            it 'fails if user has no phone number' do
              expect(user).to receive(:phone_number).and_return('')
              expect(ApiGuardian.logger).to(
                receive(:error).with 'User does not have a confirmed phone number! Cannot send OTP.'
              )
              subject.perform(user)
            end

            it 'fails if user\'s phone number is not confirmed' do
              expect(user).to receive(:phone_number).and_return(to_number)
              expect(user).to receive(:phone_number_confirmed_at).and_return(nil)
              expect(ApiGuardian.logger).to(
                receive(:error).with 'User does not have a confirmed phone number! Cannot send OTP.'
              )
              subject.perform(user)
            end
          end
        end

        context 'can send via voice' do
          before(:each) do
            expect(user).to receive(:otp_method).and_return('voice')
          end

          it 'executes when forced' do
            my_lambda = lambda { |user| }
            expect_any_instance_of(ApiGuardian::Configuration).to(
              receive(:on_send_otp_via_voice).and_return(my_lambda)
            )
            expect(my_lambda).to receive(:call)

            subject.perform(user, true)
          end

          context 'executes when user can receive voice call' do
            it 'fails if user has no phone number' do
              expect(user).to receive(:phone_number).and_return('')
              expect(ApiGuardian.logger).to receive(:error).with(
                'User does not have a confirmed phone number! Cannot send OTP.'
              )
              subject.perform(user)
            end

            it 'fails if user\'s phone number is not confirmed' do
              expect(user).to receive(:phone_number).and_return(to_number)
              expect(user).to receive(:phone_number_confirmed_at).and_return(nil)
              expect(ApiGuardian.logger).to receive(:error).with(
                'User does not have a confirmed phone number! Cannot send OTP.'
              )
              subject.perform(user)
            end
          end
        end

        it 'can send via email' do
          expect(user).to receive(:otp_method).and_return('email')
          my_lambda = lambda { |user| }
          expect_any_instance_of(ApiGuardian::Configuration).to(
            receive(:on_send_otp_via_email).and_return(my_lambda)
          )
          expect(my_lambda).to receive(:call)
          subject.perform(user)
        end

        it 'can handle google_auth' do
          expect(user).to receive(:otp_method).and_return('google_auth')
          expect(ApiGuardian.logger).to receive(:info).with(
            'User will provide code from Google Auth app'
          )
          subject.perform(user)
        end

        it 'logs error for all other cases' do
          expect(user).to receive(:otp_method).and_return('blah')
          expect(ApiGuardian.logger).to receive(:error).with(
            "No valid OTP send methods for user #{user.id}!"
          )
          subject.perform(user)
        end
      end
    end
  end
end
