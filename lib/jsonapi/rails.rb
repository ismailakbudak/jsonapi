require 'ostruct'

# Rails integration
module JSONAPI
  module Rails
    JSONAPI_PAGINATE_METHODS_MAPPING = {
      meta: :jsonapi_meta,
      links: :jsonapi_pagination,
      fields: :jsonapi_fields,
      include: :jsonapi_include,
      params: :jsonapi_serializer_params
    }

    # Updates the mime types and registers the renderers
    #
    # @return [NilClass]
    def self.install!
      return unless defined?(::Rails)

      parser = ActionDispatch::Request.parameter_parsers[:json]
      ActionDispatch::Request.parameter_parsers[:jsonapi] = parser

      self.add_renderer!
    end

    # Adds the default renderer
    #
    # @return [NilClass]
    def self.add_renderer!
      ActionController::Renderers.add(:jsonapi_paginate) do |resource, options|
        self.content_type ||= Mime[:jsonapi]

        result = {}
        JSONAPI_PAGINATE_METHODS_MAPPING.to_a[0..1].each do |opt, method_name|
          next unless respond_to?(method_name, true)
          result[opt] ||= send(method_name, resource)
        end

        # If it's an empty collection, return it directly.
        many = JSONAPI::Rails.is_collection?(resource, options[:is_collection])

        JSONAPI_PAGINATE_METHODS_MAPPING.to_a[2..-1].each do |opt, method_name|
          options[opt] ||= send(method_name) if respond_to?(method_name, true)
        end

        if options[:serializer_class]
          serializer_class = options[:serializer_class]
        else
          serializer_class = JSONAPI::Rails.serializer_class(resource, many)
        end

        options[:adapter] = :attributes
        options[:each_serializer] = serializer_class
        data = ActiveModelSerializers::SerializableResource.new(resource, options).as_json
        result[:data] = data
        result.to_json
      end
    end

    # Checks if an object is a collection
    #
    # Stolen from [JSONAPI::Serializer], instance method.
    #
    # @param resource [Object] to check
    # @param force_is_collection [NilClass] flag to overwrite
    # @return [TrueClass] upon success
    def self.is_collection?(resource, force_is_collection = nil)
      return force_is_collection unless force_is_collection.nil?

      resource.respond_to?(:size) && !resource.respond_to?(:each_pair)
    end

    # Resolves resource serializer class
    #
    # @return [Class]
    def self.serializer_class(resource, is_collection)
      klass = resource.class
      klass = resource.first.class if is_collection

      "#{klass.name}Serializer".constantize
    end
  end
end
