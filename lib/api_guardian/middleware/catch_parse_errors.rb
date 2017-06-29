module ApiGuardian
  module Middleware
    class CatchParseErrors
      def initialize(app)
        @app = app
      end

      def call(env)
        begin
          @app.call(env)
        rescue ActionDispatch::Http::Parameters::ParseError => error
          error = {
            id: SecureRandom.uuid,
            code: 'parse_error',
            status: 400,
            title: 'Parse Error',
            detail: 'The request input could not be parsed.'
          }

          [400, { "Content-Type" => "application/json" }, [ { errors: [ error ] }.to_json ]]
        end
      end
    end
  end
end