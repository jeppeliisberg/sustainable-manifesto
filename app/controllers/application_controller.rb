class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Require browser support for ES Modules, which is the foundation for import maps.
  # This is less strict than :modern but ensures all interactive features will work.
  allow_browser versions: :es6

  def index
  end

  def resources
  end
end
