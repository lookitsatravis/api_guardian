describe ApiGuardian::Helpers::Facebook do
  let(:subject) do
    ApiGuardian::Helpers::Facebook.new(
      access_token
    )
  end

  let(:access_token) { 'abc123' }

  it { should have_attr_reader(:access_token) }

  describe 'methods' do
    describe '#authorize!' do
      it 'should authorize facebook request' do
        result = { 'id' => '12345', 'name' => 'Travis Vignon', 'email' => 'test@example.com' }
        expect_any_instance_of(Koala::Facebook::API).to receive(:get_object).and_return(result)

        expect(subject.authorize!).to eq result
      end

      it 'fails when HTTP response is not 200' do
        expect_any_instance_of(Koala::Facebook::API).to(
          receive(:get_object).and_raise(Koala::KoalaError, 'oops')
        )

        expect { subject.authorize! }.to raise_error(
          ApiGuardian::Errors::IdentityAuthorizationFailed,
          'Could not connect to Facebook: oops'
        )
      end
    end
  end
end
