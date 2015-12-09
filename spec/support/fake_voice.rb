class FakeVoice
  Call = Struct.new(:from, :to, :url)

  cattr_accessor :calls
  self.calls = []

  def initialize(_account_sid, _auth_token)
  end

  def calls
    self
  end

  def create(args = {})
    self.class.calls << Call.new(from: args[:from], to: args[:to], url: args[:url])
  end
end
