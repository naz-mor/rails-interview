require 'rails_helper'

describe Base::ApplicationController do
  describe '#raise_not_found' do
    it 'raises a routing error for unsupported formats' do
      expect { controller.send(:raise_not_found) }.to raise_error(
        ActionController::RoutingError,
        'Not supported format'
      )
    end
  end
end
