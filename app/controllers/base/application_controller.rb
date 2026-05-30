module Base
  class ApplicationController < ActionController::Base
    rescue_from ActionController::UnknownFormat, with: :raise_not_found

    private

    def raise_not_found
      raise ActionController::RoutingError.new('Not supported format')
    end
  end
end
