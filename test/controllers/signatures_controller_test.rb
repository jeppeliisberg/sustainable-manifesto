require "test_helper"

class SignaturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Stub Turnstile verification to pass by default
    TurnstileVerifier.stubs(:verify).returns(true)
  end

  test "new renders step 1 form" do
    get sign_path
    assert_response :success
    assert_select "form[action=?]", signatures_path
  end

  test "create sends verification email and stores signature id in session" do
    assert_emails 1 do
      post signatures_path, params: { signature: { email: "newuser@example.com" }, "cf-turnstile-response" => "valid_token" }
    end

    assert_redirected_to verify_signatures_path
    assert_not_nil session[:signature_id]

    signature = Signature.find(session[:signature_id])
    assert_equal "newuser@example.com", signature.email
    assert_not_nil signature.confirmation_token
  end

  test "create finds existing unconfirmed signature and regenerates token" do
    existing = Signature.create!(email: "existing@example.com")
    old_token = existing.confirmation_token

    assert_emails 1 do
      post signatures_path, params: { signature: { email: "existing@example.com" }, "cf-turnstile-response" => "token" }
    end

    assert_redirected_to verify_signatures_path
    existing.reload
    assert_not_equal old_token, existing.confirmation_token
  end

  test "create shows error for already confirmed signature" do
    Signature.create!(email: "confirmed@example.com", confirmed_at: Time.current)

    post signatures_path, params: { signature: { email: "confirmed@example.com" }, "cf-turnstile-response" => "token" }

    assert_response :unprocessable_entity
    assert_match /already been confirmed/i, response.body
  end

  test "verify renders code entry form" do
    signature = Signature.create!(email: "test@example.com")
    post signatures_path, params: { signature: { email: signature.email }, "cf-turnstile-response" => "token" }

    get verify_signatures_path
    assert_response :success
    assert_select "form[action=?]", confirm_signatures_path
  end

  test "confirm sets confirmed_at and redirects to edit with valid code" do
    post signatures_path, params: { signature: { email: "newtest@example.com" }, "cf-turnstile-response" => "token" }

    signature = Signature.find_by(email: "newtest@example.com")
    code = signature.confirmation_token[0, 6]

    post confirm_signatures_path, params: { code: code }

    assert_redirected_to edit_signature_path(signature)
    signature.reload
    assert_not_nil signature.confirmed_at
  end

  test "confirm shows error with invalid code" do
    signature = Signature.create!(email: "test@example.com")
    post signatures_path, params: { signature: { email: signature.email }, "cf-turnstile-response" => "token" }

    post confirm_signatures_path, params: { code: "WRONG1" }

    assert_response :unprocessable_entity
    assert_match /invalid/i, response.body
  end

  test "throttles signature creation after 5 requests from same IP" do
    # Make 5 successful requests (the limit)
    5.times do |i|
      post signatures_path, params: { signature: { email: "user#{i}@example.com" }, "cf-turnstile-response" => "token" }, headers: { "Turbo-Frame" => "signature_form" }
      assert_response :redirect
    end

    # The 6th request should be throttled - returns 200 with error message for Turbo Frame requests
    post signatures_path, params: { signature: { email: "user6@example.com" }, "cf-turnstile-response" => "token" }, headers: { "Turbo-Frame" => "signature_form" }
    assert_response :success
    assert_match /too many/i, response.body
  end

  test "rejects submission without valid Turnstile token" do
    TurnstileVerifier.stubs(:verify).returns(false)

    post signatures_path, params: { signature: { email: "test@example.com" }, "cf-turnstile-response" => "invalid_token" }

    assert_response :unprocessable_entity
    assert_match /security verification/i, response.body
  end
end
