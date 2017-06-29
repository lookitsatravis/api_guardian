describe ApiGuardian do
  describe 'methods' do
    describe '.authenticate' do
      it 'finds provider and initiates authentication' do
        options = { foo: 'bar' }
        mock_strategy = instance_double(ApiGuardian::Strategies::Authentication::Email)

        expect(ApiGuardian::Strategies::Authentication).to(
          receive(:find_strategy).and_return(mock_strategy)
        )

        expect(ApiGuardian.logger).to receive(:info).with 'Authenticating via email'

        expect(mock_strategy).to receive(:authenticate).with(options)

        ApiGuardian.authenticate(:email, options)
      end
    end

    describe '.class_exists?' do
      it 'checks if a class exists by name' do
        expect(ApiGuardian.class_exists?('NotARealClass')).to eq false
        expect(ApiGuardian.class_exists?('ApiGuardian::Stores::UserStore')).to eq true
      end
    end
  end
end
