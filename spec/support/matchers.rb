RSpec::Matchers.define :have_content_type do |content_type|
  CONTENT_HEADER_MATCHER ||= /^(.*?)(?:; charset=(.*))?$/

  chain :with_charset do |charset|
    @charset = charset
  end

  match do
    _, content, charset = *content_type_header.match(CONTENT_HEADER_MATCHER).to_a

    if @charset
      @charset == charset && content == content_type
    else
      content == content_type
    end
  end

  failure_message do
    if @charset
      "Content type #{content_type_header.inspect} should match #{content_type.inspect} with charset #{@charset}"
    else
      "Content type #{content_type_header.inspect} should match #{content_type.inspect}"
    end
  end

  failure_message_when_negated do
    if @charset
      "Content type #{content_type_header.inspect} should not match #{content_type.inspect} with charset #{@charset}"
    else
      "Content type #{content_type_header.inspect} should not match #{content_type.inspect}"
    end
  end

  def content_type_header
    response.headers['Content-Type']
  end
end

# RSpec matcher for validates_with.
# https://gist.github.com/2032846
# Usage:
#
#     describe User do
#       it { should validate_with CustomValidator }
#     end
RSpec::Matchers.define :validate_with do |expected_validator|
  match do |subject|
    @validator = subject.class.validators.find do |validator|
      validator.class == expected_validator
    end
    @validator.present? && options_matching?
  end

  def options_matching?
    if @options.present?
      @options.all? { |option| @validator.options[option] == @options[option] }
    else
      true
    end
  end

  chain :with_options do |opts|
    @options = opts
  end

  description do
    "RSpec matcher for validates_with"
  end

  failure_message do
    "expected to validate with #{validator}#{@options.present? ? (' with options ' + @options) : ''}"
  end

  failure_message_when_negated do
    "do not expected to validate with #{validator}#{@options.present? ? (' with options ' + @options) : ''}"
  end
end
