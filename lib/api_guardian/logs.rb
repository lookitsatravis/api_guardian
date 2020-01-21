# frozen_string_literal: true

module ApiGuardian
  module Logging
    class Logger < ActiveSupport::Logger
      def initialize(*args)
        super
        @formatter = Formatter.new
      end

      class Formatter < ActiveSupport::Logger::SimpleFormatter
        COLORS = {
          'black'   => 0,
          'red'     => 1,
          'green'   => 2,
          'yellow'  => 3,
          'blue'    => 4,
          'purple'  => 5,
          'magenta' => 5,
          'cyan'    => 6,
          'white'   => 7
        }.freeze

        COLORS.each_pair do |color, value|
          define_method color do |text|
            "\033[0;#{30 + value}m#{text}\033[0m"
          end

          define_method "light_#{color}" do |text|
            "\033[1;#{30 + value}m#{text}\033[0m"
          end
        end

        def call(severity, _time, _progname, msg)
          response = '[' + cyan('ApiGuardian') + '] '

          request_id = ApiGuardian.current_request ? ApiGuardian.current_request.uuid : nil
          response += '[' + light_green(request_id) + '] ' if request_id

          msg = msg.is_a?(String) ? msg : msg.inspect

          response += "[#{formatted_severity(severity)}] #{msg}\n"
          response
        end

        private

        def formatted_severity(severity)
          case severity
          when 'WARN'
            yellow(severity)
          when 'ERROR'
            light_red(severity)
          when 'FATAL'
            red(severity)
          when 'INFO'
            green(severity)
          else
            severity
          end
        end
      end
    end
  end
end
