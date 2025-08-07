require "rack/utils"

module JSONAPI
  # Helpers to handle some error responses
  #
  # Most of the exceptions are handled in Rails by [ActionDispatch] middleware
  # See: https://api.rubyonrails.org/classes/ActionDispatch/ExceptionWrapper.html
  module Errors
    # Callback will register the error handlers
    #
    # @return [Module]
    def self.included(base)
      base.class_eval do
        rescue_from(
          StandardError,
          with: :render_jsonapi_internal_server_error
        )

        rescue_from(
          ActiveRecord::RecordNotFound,
          with: :render_jsonapi_not_found
        )

        rescue_from(
          ActionController::ParameterMissing,
          with: :render_jsonapi_unprocessable_entity
        )
      end
    end

    private
      # Generic error handler callback
      #
      # @param exception [Exception] instance to handle
      # @return [String] JSONAPI error response
      def render_jsonapi_internal_server_error(exception)
        error = {
          status: "500",
          code: "internal_server_error",
          title: Rack::Utils::HTTP_STATUS_CODES[500],
          detail: exception.message
        }
        render jsonapi_errors: [ error ], status: :internal_server_error
      end

      # Not found (404) error handler callback
      #
      # @param exception [Exception] instance to handle
      # @return [String] JSONAPI error response
      def render_jsonapi_not_found(exception)
        error = {
          status: "404",
          code: "not_found",
          title: Rack::Utils::HTTP_STATUS_CODES[404],
          detail: "Resource not found"
        }
        render jsonapi_errors: [ error ], status: :not_found
      end

      # Unprocessable entity (422) error handler callback
      #
      # @param exception [Exception] instance to handle
      # @return [String] JSONAPI error response
      def render_jsonapi_unprocessable_entity(exception)
        error = {
          status: "422",
          code: "unprocessable_entity",
          title: Rack::Utils::HTTP_STATUS_CODES[422],
          detail: "Required parameter missing or invalid"
        }

        render jsonapi_errors: [ error ], status: :unprocessable_content
      end
  end
end
