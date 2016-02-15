describe ApiGuardian::Helpers::Digits do
  let(:subject) do
    ApiGuardian::Helpers::Digits.new(
      auth_url,
      auth_header
    )
  end

  let(:auth_url) { 'https://api.digits.com/v1/something.json' }
  let(:auth_header) { 'OAuth oauth_consumer_key="foo"' }

  it { should have_attr_reader(:auth_url) }
  it { should have_attr_reader(:auth_header) }

  describe 'methods' do
    describe '#validate' do
      it 'fails when oauth key is missing' do
        expect_any_instance_of(ApiGuardian::Configuration::Registration).to(
          receive(:digits_key).and_return('')
        )

        result = subject.validate

        expect(result.succeeded).to eq false
        expect(result.error).to eq(
          'Digits consumer key not set! Please add ' \
          '"config.registration.digits_key" to the ApiGuardian initializer!'
        )
      end

      it 'fails with invalid auth header' do
        expect_any_instance_of(ApiGuardian::Configuration::Registration).to(
          receive(:digits_key).twice.and_return('bar')
        )

        result = subject.validate

        expect(result.succeeded).to eq false
        expect(result.error).to eq 'Digits consumer key does not match this request.'
      end

      context 'with invalid auth url' do
        let(:auth_url) { 'https://example.com/stuff.json' }

        it 'fails with invalid auth url' do
          expect_any_instance_of(ApiGuardian::Configuration::Registration).to(
            receive(:digits_key).twice.and_return('foo')
          )

          result = subject.validate

          expect(result.succeeded).to eq false
          expect(result.error).to eq 'Auth url is for invalid domain. Must match "api.digits.com".'
        end
      end

      it 'succeeds if validations pass' do
        expect_any_instance_of(ApiGuardian::Configuration::Registration).to(
          receive(:digits_key).twice.and_return('foo')
        )

        result = subject.validate

        expect(result.succeeded).to eq true
        expect(result.error).to eq ''
      end
    end

    describe '#authorize!' do
      it 'should authorize digits request' do
        stub_request(:get, auth_url)
          .to_return(status: 200)

        expect(subject.authorize!).to be_a Net::HTTPResponse

        expect(WebMock).to have_requested(:get, auth_url)
          .with(headers: {'Authorization' => auth_header}).once
      end

      it 'fails when HTTP response is not 200' do
        stub_request(:get, auth_url)
          .to_return(status: 400)

        expect { subject.authorize! }.to raise_error(
          ApiGuardian::Errors::IdentityAuthorizationFailed,
          'Digits API responded with 400. Expected 200!'
        )

        expect(WebMock).to have_requested(:get, auth_url)
          .with(headers: {'Authorization' => auth_header}).once
      end
    end
  end
end
