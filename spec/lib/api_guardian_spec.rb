# frozen_string_literal: true

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

      it 'executes on_login_success lambda when a user is logged in' do
        my_lambda = lambda { |_user| }
        options = { foo: 'bar' }
        mock_user = mock_model(ApiGuardian::User)
        mock_strategy = instance_double(ApiGuardian::Strategies::Authentication::Email)

        expect(ApiGuardian::Strategies::Authentication).to(
          receive(:find_strategy).and_return(mock_strategy)
        )

        expect(mock_strategy).to receive(:authenticate).with(options).and_return(mock_user)
        expect_any_instance_of(ApiGuardian::Configuration).to receive(:on_login_success).and_return(my_lambda)
        expect(my_lambda).to receive(:call)

        ApiGuardian.authenticate(:email, options)
      end

      it 'executes on_login_failure lambda when a user is not logged in' do
        my_lambda = lambda { |_provider, _options| }
        options = { foo: 'bar' }
        mock_strategy = instance_double(ApiGuardian::Strategies::Authentication::Email)

        expect(ApiGuardian::Strategies::Authentication).to(
          receive(:find_strategy).and_return(mock_strategy)
        )

        expect(mock_strategy).to receive(:authenticate).with(options).and_return(nil)
        expect_any_instance_of(ApiGuardian::Configuration).to receive(:on_login_failure).and_return(my_lambda)
        expect(my_lambda).to receive(:call)

        ApiGuardian.authenticate(:email, options)
      end
    end

    describe '.class_exists?' do
      it 'checks if a class exists by name' do
        expect(ApiGuardian.class_exists?('NotARealClass')).to eq false
        expect(ApiGuardian.class_exists?('ApiGuardian::Stores::UserStore')).to eq true
      end
    end

    describe '.find_user_store' do
      it 'checks for an app-specific user store, otherwise returns the ApiGuardian user store' do
        expect(ApiGuardian.find_user_store).to be_a ApiGuardian::Stores::UserStore.class

        # Create a UserStore class
        Object.const_set('UserStore', Class.new { def method1() 42 end })

        # If the UserStore exists, then it should be returned and not the ApiGuardian UserStore
        expect(ApiGuardian.find_user_store).to be_a UserStore.class

        Object.send(:remove_const, :UserStore)
      end
    end
  end
end
