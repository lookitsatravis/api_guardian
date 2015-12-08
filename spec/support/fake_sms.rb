class FakeSMS
  Message = Struct.new(:from, :to, :body)

  cattr_accessor :messages
  self.messages = []

  def initialize(_account_sid, _auth_token)
  end

  def messages
    self
  end

  def create(args = {})
    self.class.messages << Message.new(from: args[:from], to: args[:to], body: args[:body])
  end
end
