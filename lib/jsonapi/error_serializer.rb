module JSONAPI
  # Serializer for JSON:API error responses
  #
  # Handles serialization of errors according to JSON:API specification
  # See: https://jsonapi.org/format/#errors
  class ErrorSerializer
    attr_reader :errors, :options

    def initialize(errors, options = {})
      @errors = if errors.is_a?(ActiveModel::Errors)
                  errors.errors
                else
                  Array(errors)
                end
      @options = options
    end

    def to_json(*args)
      { errors: serialized_errors }.to_json(*args)
    end

    private

    def serialized_errors
      errors.map do |error|
        if error.is_a?(Array) && error.size == 2
          # Handle [attribute, error_hash] format from rails_app.rb
          serialize_validation_error(error[0], error[1])
        elsif error.is_a?(Hash)
          # Handle direct hash format
          serialize_hash_error(error)
        else
          # Handle generic errors
          serialize_generic_error(error)
        end
      end
    end

    def serialize_validation_error(attribute, error)
      {
        status: error[:status] || "422",
        key: error[:key] || "invalid",
        title: error[:title] || "Error",
        detail: error[:message],
        attribute: attribute,
      }.compact
    end

    def serialize_hash_error(error)
      {
        status: error[:status] || "422",
        key: error[:key] || "invalid",
        title: error[:title] || "Error",
        detail: error[:detail] || error["detail"],
      }.compact
    end

    def serialize_generic_error(error)
      {
        status: "422",
        key: error.type,
        title: "Error",
        detail: error.full_message,
        attribute: error.attribute,
      }
    end
  end
end
