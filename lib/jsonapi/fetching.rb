module JSONAPI
  # Inclusion and sparse fields support
  module Fetching
    private
      # Extracts and formats sparse fieldsets for Active Model Serializers
      #
      # Ex.: `GET /resource?fields[relationship]=id,created_at`
      #
      # @return [Hash] in Active Model Serializers format
      def jsonapi_fields
        return unless params[:fields].respond_to?(:each_pair)

        result = []
        
        params[:fields].each do |k, v|
          field_names = v.to_s.split(",").map(&:strip).compact.map(&:to_sym)
          result << { k.to_sym => field_names }
        end

        result
      end

      # Extracts and whitelists allowed includes
      #
      # Ex.: `GET /resource?include=relationship,relationship.subrelationship`
      #
      # @return [Array]
      def jsonapi_include
        params["include"].to_s.split(",").map(&:strip).compact
      end
  end
end
