require 'faker'

describe 'ApiGuardian::ApplicationController' do
  # Authentication and permissions are tested elsewhere
  before(:each) { @routes = ApiGuardian::Engine.routes }

  describe 'Missing route catcher' do
    it 'renders not found' do
      %w(GET POST PUT PATCH DELETE HEAD).each do |method|
        random_route = []

        rand(1..4).times do
          random_route << Faker::Internet.slug(Faker::Lorem.words(4).join(' '), '-')
        end

        send(method.downcase, '/' + random_route.join('/'))

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
