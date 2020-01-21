# frozen_string_literal: true

describe ApiGuardian::Strategies::Authentication do
  describe 'methods' do
    describe '.find_strategy' do
      it 'fails if a strategy is nil' do
        expect { ApiGuardian::Strategies::Authentication.find_strategy(nil) }.to(
          raise_error ApiGuardian::Errors::InvalidAuthenticationProvider
        )
      end

      it 'finds a registered strategy' do
        mock_array = double([])
        expect(ApiGuardian::Strategies::Authentication::Base).to receive(:providers).and_return(mock_array)
        expect(mock_array).to receive(:[]).and_return(:test)
        expect { ApiGuardian::Strategies::Authentication.find_strategy(:test) }.not_to raise_error
      end

      it 'fails if strategy is not found' do
        mock_array = double([])
        expect(ApiGuardian::Strategies::Authentication::Base).to receive(:providers).twice.and_return(mock_array)
        expect(mock_array).to receive(:[]).and_return(nil)
        expect(mock_array).to receive(:keys).and_return([])
        expect { ApiGuardian::Strategies::Authentication.find_strategy(:test) }.to(
          raise_error ApiGuardian::Errors::InvalidAuthenticationProvider
        )
      end
    end
  end
end
