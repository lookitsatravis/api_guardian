# frozen_string_literal: true

describe ApiGuardian::Logging::Logger::Formatter do
  describe 'initialization' do
    it 'should create methods for each supported color' do
      expect(subject.respond_to?('black')).to eq true
      expect(subject.respond_to?('light_black')).to eq true
      expect(subject.respond_to?('red')).to eq true
      expect(subject.respond_to?('light_red')).to eq true
      expect(subject.respond_to?('green')).to eq true
      expect(subject.respond_to?('light_green')).to eq true
      expect(subject.respond_to?('yellow')).to eq true
      expect(subject.respond_to?('light_yellow')).to eq true
      expect(subject.respond_to?('blue')).to eq true
      expect(subject.respond_to?('light_blue')).to eq true
      expect(subject.respond_to?('purple')).to eq true
      expect(subject.respond_to?('light_purple')).to eq true
      expect(subject.respond_to?('magenta')).to eq true
      expect(subject.respond_to?('light_magenta')).to eq true
      expect(subject.respond_to?('cyan')).to eq true
      expect(subject.respond_to?('light_cyan')).to eq true
      expect(subject.respond_to?('white')).to eq true
      expect(subject.respond_to?('light_white')).to eq true
    end
  end

  # Methods
  describe 'methods' do
    describe '##{color}' do
      it 'return properly formatted strings' do
        expect(subject.black('test')).to eq "\033[0;#{30 + 0}mtest\033[0m"
        expect(subject.light_black('test')).to eq "\033[1;#{30 + 0}mtest\033[0m"
        expect(subject.red('test')).to eq "\033[0;#{30 + 1}mtest\033[0m"
        expect(subject.light_red('test')).to eq "\033[1;#{30 + 1}mtest\033[0m"
        expect(subject.green('test')).to eq "\033[0;#{30 + 2}mtest\033[0m"
        expect(subject.light_green('test')).to eq "\033[1;#{30 + 2}mtest\033[0m"
        expect(subject.yellow('test')).to eq "\033[0;#{30 + 3}mtest\033[0m"
        expect(subject.light_yellow('test')).to eq "\033[1;#{30 + 3}mtest\033[0m"
        expect(subject.blue('test')).to eq "\033[0;#{30 + 4}mtest\033[0m"
        expect(subject.light_blue('test')).to eq "\033[1;#{30 + 4}mtest\033[0m"
        expect(subject.purple('test')).to eq "\033[0;#{30 + 5}mtest\033[0m"
        expect(subject.light_purple('test')).to eq "\033[1;#{30 + 5}mtest\033[0m"
        expect(subject.magenta('test')).to eq "\033[0;#{30 + 5}mtest\033[0m"
        expect(subject.light_magenta('test')).to eq "\033[1;#{30 + 5}mtest\033[0m"
        expect(subject.cyan('test')).to eq "\033[0;#{30 + 6}mtest\033[0m"
        expect(subject.light_cyan('test')).to eq "\033[1;#{30 + 6}mtest\033[0m"
        expect(subject.white('test')).to eq "\033[0;#{30 + 7}mtest\033[0m"
        expect(subject.light_white('test')).to eq "\033[1;#{30 + 7}mtest\033[0m"
      end
    end

    describe '#call' do
      let(:mock_request) { instance_double(ActionDispatch::Request) }

      describe 'WARN call' do
        it 'formats and logs passed in data' do
          expect(ApiGuardian).to receive(:current_request).twice.and_return(mock_request)
          expect(mock_request).to receive(:uuid).and_return('12345')

          result = subject.call 'WARN', nil, nil, 'Test warning.'

          expect(result).to eq(
            "[\033[0;36mApiGuardian\033[0m] [\033[1;32m12345\033[0m] [\033[0;33mWARN\033[0m] Test warning.\n"
          )
        end
      end

      describe 'ERROR call' do
        it 'formats and logs passed in data' do
          expect(ApiGuardian).to receive(:current_request).twice.and_return(mock_request)
          expect(mock_request).to receive(:uuid).and_return('12345')

          result = subject.call 'ERROR', nil, nil, 'Test error.'

          expect(result).to eq(
            "[\033[0;36mApiGuardian\033[0m] [\033[1;32m12345\033[0m] [\033[1;31mERROR\033[0m] Test error.\n"
          )
        end
      end

      describe 'FATAL call' do
        it 'formats and logs passed in data' do
          expect(ApiGuardian).to receive(:current_request).twice.and_return(mock_request)
          expect(mock_request).to receive(:uuid).and_return('12345')

          result = subject.call 'FATAL', nil, nil, 'Test fatal.'

          expect(result).to eq(
            "[\033[0;36mApiGuardian\033[0m] [\033[1;32m12345\033[0m] [\033[0;31mFATAL\033[0m] Test fatal.\n"
          )
        end
      end

      describe 'INFO call' do
        it 'formats and logs passed in data' do
          expect(ApiGuardian).to receive(:current_request).twice.and_return(mock_request)
          expect(mock_request).to receive(:uuid).and_return('12345')

          result = subject.call 'INFO', nil, nil, 'Test info.'

          expect(result).to eq(
            "[\033[0;36mApiGuardian\033[0m] [\033[1;32m12345\033[0m] [\033[0;32mINFO\033[0m] Test info.\n"
          )
        end
      end
    end
  end
end
