class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Require browser support for import maps, which is the foundation for our JavaScript architecture.
  # These are the minimum versions that support import maps natively.
  allow_browser versions: { safari: 16.4, chrome: 89, firefox: 109, opera: 75, ie: false }

  def index
  end

  def resources
  end
end
