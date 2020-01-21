# frozen_string_literal: true

module Doorkeeper
  describe ApplicationMetalController do
    it 'should handle TwoFactorRequired error' do
      expect(subject.methods).to include(:two_factor_required)
      expect(subject.rescue_handlers).to include(
        ['ApiGuardian::Errors::TwoFactorRequired', :two_factor_required]
      )
    end

    it 'should register current_request filter for ApiGuardian' do
      # https://blog.pivotal.io/labs/labs/revealing-the-actioncontroller-callback-filter-chain
      registered_callbacks = subject._process_action_callbacks.map(&:filter)

      expect(registered_callbacks).to include(:set_current_request)
    end

    describe 'methods' do
      describe '#set_current_request' do
        it 'should set the request with ApiGuardian' do
          expect(ApiGuardian).to receive(:current_request=).with subject.request

          subject.set_current_request
        end
      end
    end
  end
end
