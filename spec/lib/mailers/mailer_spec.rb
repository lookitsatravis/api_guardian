describe ApiGuardian::Mailers::Mailer do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe 'otp' do
    let(:user) { create(:user) }
    before(:each) do
      ApiGuardian::Mailers::Mailer.one_time_password(user).deliver_now
    end

    it 'should send an email' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'renders the receiver email' do
      expect(ActionMailer::Base.deliveries.first.to).to eq [user.email]
    end

    it 'should set the subject to the correct subject' do
      expect(ActionMailer::Base.deliveries.first.subject).to eq 'Your authentication code.'
    end

    it 'renders the sender email' do
      expect(ActionMailer::Base.deliveries.first.from).to eq [ApiGuardian.configuration.mail_from_address]
    end

    it 'renders the proper body' do
      expect(ActionMailer::Base.deliveries.first.body).to match(/<p>Your authentication code is ([\d]){6}.<\/p>/)
    end
  end
end
