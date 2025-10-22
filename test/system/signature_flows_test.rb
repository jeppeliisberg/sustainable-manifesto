require "application_system_test_case"

class SignatureFlowsTest < ApplicationSystemTestCase
  setup do
    # Stub Turnstile verification
    TurnstileVerifier.stubs(:verify).returns(true)
  end

  test "complete individual signature flow" do
    visit sign_path

    # Step 1: Enter name and email
    fill_in "Full Name", with: "Jane Doe"
    fill_in "Email Address", with: "jane@example.com"
    click_button "Continue"

    # Verify email step - wait for page to load
    assert_text "Verification Code"
    signature = Signature.find_by(email: "jane@example.com")
    code = signature.confirmation_token[0, 6]

    # Fill in verification code digits
    code.chars.each_with_index do |char, index|
      find("input[name='code_#{index}']").set(char)
    end
    click_button "Verify"

    # Step 2: Select signature type
    assert_text "Are you signing as an individual or organization?"
    choose "Individual"
    click_button "Continue"

    # Step 3: Individual details
    assert_text "Tell us a bit more"
    fill_in "Job Title", with: "Software Engineer"
    click_button "Sign the Manifesto"

    # Success
    assert_text "Thank you for signing"
    signature.reload
    assert_not_nil signature.signed_at
  end

  test "complete organization signature flow" do
    visit sign_path

    # Step 1: Enter name and email
    fill_in "Full Name", with: "John Smith"
    fill_in "Email Address", with: "john@acme.com"
    click_button "Continue"

    # Verify email - wait for page to load
    assert_text "Verification Code"
    signature = Signature.find_by(email: "john@acme.com")
    code = signature.confirmation_token[0, 6]

    # Fill in verification code digits
    code.chars.each_with_index do |char, index|
      find("input[name='code_#{index}']").set(char)
    end
    click_button "Verify"

    # Step 2: Select organization
    choose "Organization"
    click_button "Continue"

    # Step 3: Organization details
    assert_text "Organization details"
    fill_in "Organization Name", with: "Acme Corp"
    fill_in "Organization Website", with: "https://acme.com"
    click_button "Sign the Manifesto"

    # Success
    assert_text "Thank you for signing"
    signature.reload
    assert_not_nil signature.signed_at
    assert_equal "organization", signature.signature_type
  end

  test "go back navigation works" do
    visit sign_path

    # Complete step 1
    fill_in "Full Name", with: "Test User"
    fill_in "Email Address", with: "test@example.com"
    click_button "Continue"

    # Verify - wait for page to load
    assert_text "Verification Code"
    signature = Signature.find_by(email: "test@example.com")
    code = signature.confirmation_token[0, 6]

    # Fill in verification code digits
    code.chars.each_with_index do |char, index|
      find("input[name='code_#{index}']").set(char)
    end
    click_button "Verify"

    # On type selection
    choose "Individual"
    click_button "Continue"

    # On details page
    assert_text "Tell us a bit more"

    # Go back to type selection
    click_link "Go back"
    assert_text "Are you signing as an individual or organization?"

    # Can change selection
    choose "Organization"
    click_button "Continue"
    assert_text "Organization details"
  end

  test "resume abandoned signature flow" do
    # Create a verified but incomplete signature
    signature = Signature.create!(
      name: "Existing User",
      email: "existing@example.com",
      confirmed_at: Time.current,
      signature_type: :individual
    )

    # Try to sign again with same email
    visit sign_path
    fill_in "Full Name", with: "Existing User"
    fill_in "Email Address", with: "existing@example.com"
    click_button "Continue"

    # Should get verification code
    assert_text "Verification Code"

    # Verify with new code
    signature.reload
    code = signature.confirmation_token[0, 6]

    # Fill in verification code digits
    code.chars.each_with_index do |char, index|
      find("input[name='code_#{index}']").set(char)
    end
    click_button "Verify"

    # Should start at type selection (not skip to details)
    assert_text "Are you signing as an individual or organization?"

    # Complete flow
    choose "Individual"
    click_button "Continue"
    click_button "Sign the Manifesto"

    assert_text "Thank you for signing"
    signature.reload
    assert_not_nil signature.signed_at
  end

  test "cannot sign twice with same email" do
    # Create fully signed signature
    Signature.create!(
      name: "Already Signed",
      email: "signed@example.com",
      confirmed_at: Time.current,
      signed_at: Time.current
    )

    visit sign_path
    fill_in "Full Name", with: "Already Signed"
    fill_in "Email Address", with: "signed@example.com"
    click_button "Continue"

    assert_text "already signed"
  end
end
