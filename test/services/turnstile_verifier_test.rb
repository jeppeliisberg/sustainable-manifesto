require "test_helper"
require "webmock/minitest"

class TurnstileVerifierTest < ActiveSupport::TestCase
  test "verify returns true for valid token" do
    stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
      .with(body: hash_including("response" => "valid_token"))
      .to_return(status: 200, body: { success: true }.to_json)

    assert TurnstileVerifier.verify("valid_token")
  end

  test "verify returns false for invalid token" do
    stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
      .with(body: hash_including("response" => "invalid_token"))
      .to_return(status: 200, body: { success: false }.to_json)

    assert_not TurnstileVerifier.verify("invalid_token")
  end

  test "verify returns false for blank token" do
    assert_not TurnstileVerifier.verify("")
    assert_not TurnstileVerifier.verify(nil)
  end

  test "verify includes remote_ip when provided" do
    stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
      .with(body: hash_including("response" => "token", "remoteip" => "127.0.0.1"))
      .to_return(status: 200, body: { success: true }.to_json)

    assert TurnstileVerifier.verify("token", "127.0.0.1")
  end

  test "verify returns false on network error" do
    stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
      .to_raise(StandardError.new("Network error"))

    assert_not TurnstileVerifier.verify("token")
  end
end
