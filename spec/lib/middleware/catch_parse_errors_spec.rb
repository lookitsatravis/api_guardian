# frozen_string_literal: true

class TestApp
  def call(env)
    if env == 'ok'
      true
    else
      begin
        raise NameError
      rescue
        raise ActionDispatch::Http::Parameters::ParseError.new
      end
    end
  end
end

describe ApiGuardian::Middleware::CatchParseErrors do
  subject { ApiGuardian::Middleware::CatchParseErrors.new(TestApp.new) }

  describe '#call' do
    it 'will execute the next middleware and render ActionDispatch::Http::Parameters::ParseErrors' do
      expect { subject.call('ok') }.not_to raise_error

      result = subject.call('fail')

      expect(result[0]).to eq 400
      expect(result[1]).to eq({ 'Content-Type' => 'application/json' })
      expect(result[2]).to be_a Array
      expect(result[2].size).to eq 1
      expect(result[2][0]).to be_a String

      # Check the error contents
      json = JSON.parse(result[2][0])

      expect(json['errors']).to be_a Array
      expect(json['errors'][0]).to be_a Hash
      expect(json['errors'][0]['id']).to be_a String
      expect(json['errors'][0]['id'].length).to eq 36
      expect(json['errors'][0]['code']).to eq 'parse_error'
      expect(json['errors'][0]['status']).to eq 400
      expect(json['errors'][0]['title']).to eq 'Parse Error'
      expect(json['errors'][0]['detail']).to eq 'The request input could not be parsed.'
    end
  end
end
