# frozen_string_literal: true

require "net/http"
require "json"

class TurnstileVerifier
  VERIFY_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify"

  def self.verify(token, remote_ip = nil)
    new(token, remote_ip).verify
  end

  def initialize(token, remote_ip = nil)
    @token = token
    @remote_ip = remote_ip
    @secret_key = Rails.application.credentials.dig(:turnstile, :secret_key)
  end

  def verify
    return false if @token.blank?
    return false if @secret_key.blank?

    uri = URI(VERIFY_URL)
    response = Net::HTTP.post_form(uri, build_params)
    result = JSON.parse(response.body)

    result["success"] == true
  rescue StandardError => e
    Rails.logger.error("Turnstile verification failed: #{e.message}")
    false
  end

  private

  def build_params
    params = {
      "secret" => @secret_key,
      "response" => @token
    }
    params["remoteip"] = @remote_ip if @remote_ip.present?
    params
  end
end
