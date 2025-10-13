# frozen_string_literal: true

class Rack::Attack
  # Use Rails cache for storing throttle data
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle signature creation attempts by IP address
  # Allow 5 requests per 15 minutes per IP
  throttle("signatures/create", limit: 5, period: 15.minutes) do |req|
    if req.path == "/signatures" && req.post?
      req.ip
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    retry_after = match_data[:period]

    # Check if this is a Turbo Frame request
    if request.env["HTTP_TURBO_FRAME"]
      # Render a Turbo Frame-compatible response with 200 status
      # Turbo Frame only accepts 2xx responses for frame updates
      body = <<~HTML
        <turbo-frame id="signature_form">
          <div class="bg-white p-8 rounded-lg shadow-lg max-w-md w-full">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">Too Many Requests</h2>
            <div class="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded mb-4">
              You've made too many signature attempts. Please try again in a few minutes.
            </div>
            <div class="text-center">
              <a href="/" data-turbo-frame="_top" class="text-sm text-gray-600 hover:text-gray-800">Go back</a>
            </div>
          </div>
        </turbo-frame>
      HTML
      status = 200
    else
      body = "<html><body><h1>Too Many Requests</h1><p>Please try again later.</p></body></html>"
      status = 429
    end

    [
      status,
      { "Content-Type" => "text/html", "Retry-After" => retry_after.to_s },
      [ body ]
    ]
  end
end
