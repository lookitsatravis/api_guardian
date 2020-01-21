# frozen_string_literal: true

module Test
  class FoosController < ApiGuardian::ApiController
  end
end

class ApiGuardian::Stores::FooStore < ApiGuardian::Stores::Base
end

class ApiGuardian::FooSerializer < ApiGuardian::Serializers::Base
end

class Foo < ActiveRecord::Base
end

module Test
  class BarsController < ApiGuardian::ApiController
  end
end

class BarStore < ApiGuardian::Stores::Base
end

class BarSerializer < ApiGuardian::Serializers::Base
end

class Bar < ActiveRecord::Base
end

module Test
  class BazsController < ApiGuardian::ApiController
  end
end

class BazIndexSerializer < ApiGuardian::Serializers::Base
end

module Test
  class IdentitiesController < ApiGuardian::ApiController
  end
end

class Qux < ActiveRecord::Base
end

RSpec.describe ApiGuardian::ApiController do
  let(:dummy_class) { Test::FoosController.new }
  let(:dummy2_class) { Test::BarsController.new }
  let(:dummy3_class) { Test::BazsController.new }
  let(:dummy4_class) { Test::IdentitiesController.new }

  before(:each) do
    dummy_class.class.send(:public, *dummy_class.class.protected_instance_methods)
    dummy2_class.class.send(:public, *dummy2_class.class.protected_instance_methods)
    dummy3_class.class.send(:public, *dummy3_class.class.protected_instance_methods)
    dummy4_class.class.send(:public, *dummy4_class.class.protected_instance_methods)
  end

  # Methods
  describe 'methods' do
    describe '#resource_store' do
      it 'is able to find a store for a controller' do
        result1 = dummy_class.resource_store

        expect(result1).to be_a ApiGuardian::Stores::FooStore

        result2 = dummy2_class.resource_store

        expect(result2).to be_a BarStore

        expect { dummy3_class.resource_store }.to raise_error(
          ApiGuardian::Errors::ResourceStoreMissing, 'Could not find a resource store ' \
          'for Baz. Have you created one? You can override `#resource_store` ' \
          'in your controller in order to set it up specifically.'
        )
      end
    end

    describe '#resource_serializer' do
      it 'is able to find a serializer for a resource' do
        result1 = dummy_class.resource_serializer

        expect(result1).to eq ApiGuardian::FooSerializer

        result2 = dummy2_class.resource_serializer

        expect(result2).to eq BarSerializer

        dummy3_class.action_name = 'index'
        result3 = dummy3_class.resource_serializer

        expect(result3).to eq BazIndexSerializer

        expect { dummy4_class.resource_serializer }.to raise_error(
          ApiGuardian::Errors::ResourceSerializerMissing, 'Could not find a resource serializer ' \
          'for Identity. Have you created IdentitySerializer?'
        )
      end
    end

    describe '#resource_class' do
      it 'is able to find a model class for a resource' do
        result1 = dummy_class.resource_class

        expect(result1.to_s).to eq 'Foo'

        result2 = dummy2_class.resource_class

        expect(result2.to_s).to eq 'Bar'

        expect { dummy3_class.resource_class }.to raise_error(
          ApiGuardian::Errors::ResourceClassMissing, 'Could not find a resource class ' \
          '(model) for Baz. Have you created one?'
        )

        # And with user, which is provided by ApiGuardian

        ApiGuardian.configuration.identity_class = 'Qux'

        result4 = dummy4_class.resource_class

        expect(result4.to_s).to eq 'Qux'
      end
    end
  end
end
