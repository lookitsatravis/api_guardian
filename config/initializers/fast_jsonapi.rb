# frozen_string_literal: true

# To make AMS migration easier, we need to pluralize types
# https://github.com/Netflix/fast_jsonapi/issues/301

module FastJsonapi
  module ObjectSerializer
    class_methods do
      def pluralize(type_name, options = {})
        run_key_transform((options[:serializer] || options[:record_type] || type_name).to_s.pluralize)
      end

      alias_method :original_set_type, :set_type
      def set_type(type_name)
        original_set_type pluralize(type_name)
      end

      alias_method :original_belongs_to, :belongs_to
      def belongs_to(type_name, options = {}, &block)
        options[:record_type] = pluralize(type_name, options)
        original_belongs_to type_name, options, &block
      end

      alias_method :original_has_one, :has_one
      def has_one(type_name, options = {}, &block)
        options[:record_type] = pluralize(type_name, options)
        original_has_one type_name, options, &block
      end

      alias_method :original_has_many, :has_many
      def has_many(type_name, options = {}, &block)
        options[:record_type] = pluralize(type_name, options)
        original_has_many type_name, options, &block
      end
    end
  end
end
