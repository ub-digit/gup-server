class V1::V1Controller < ApplicationController

  class V1::ControllerError < StandardError
    attr_reader :code
    attr_reader :errors
    attr_reader :message
    def initialize(code: ErrorCodes::ERROR, errors: {}, message: '')
      @code = code
      @errors = errors
      super(message)
    end
  end

  before_filter :validate_access
end
