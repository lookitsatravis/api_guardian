module Test
  class DummyController < ApiGuardian::ApiController
  end
end

class ApiGuardian::Stores::DummyStore < ApiGuardian::Stores::Base
end

module Test
  class Dummy2Controller < ApiGuardian::ApiController
  end
end

class Dummy2Store < ApiGuardian::Stores::Base
end

module Test
  class Dummy3Controller < ApiGuardian::ApiController
  end
end

RSpec.describe ApiGuardian::ApiController do
  let(:dummy_class) { Test::DummyController.new }
  let(:dummy2_class) { Test::Dummy2Controller.new }
  let(:dummy3_class) { Test::Dummy3Controller.new }

  before(:each) do
    dummy_class.class.send(:public, *dummy_class.class.protected_instance_methods)
    dummy2_class.class.send(:public, *dummy2_class.class.protected_instance_methods)
    dummy3_class.class.send(:public, *dummy3_class.class.protected_instance_methods)
  end

  # Methods
  describe 'methods' do
    describe '#resource_store' do
      it 'is able to find a store for a controller' do
        result1 = dummy_class.resource_store

        expect(result1).to be_a ApiGuardian::Stores::DummyStore

        result2 = dummy2_class.resource_store

        expect(result2).to be_a Dummy2Store

        expect { dummy3_class.resource_store }.to raise_error(
          ApiGuardian::Errors::ResourceStoreMissing, "Could not find a resource store " \
               "for Dummy3. Have you created one? You can override `#resource_store` " \
               "in your controller in order to set it up specifically."
        )
      end
    end
  end
end
