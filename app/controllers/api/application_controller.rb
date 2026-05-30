module Api
  class ApplicationController < Base::ApplicationController
    skip_forgery_protection
  end
end
