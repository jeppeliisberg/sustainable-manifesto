require "application_system_test_case"

class SignaturesInfiniteScrollTest < ApplicationSystemTestCase
  setup do
    # 55 signed signatures: the newest 50 fill page 1, the oldest 5 land on page 2
    55.times do |i|
      Signature.create!(
        email: "signer#{i}@example.com",
        name: "Signer #{format('%02d', i)}",
        signature_type: :individual,
        confirmed_at: 1.day.ago,
        signed_at: 1.day.ago,
        created_at: (100 - i).minutes.ago
      )
    end
  end

  test "scrolling to the bottom loads the next page of signatures" do
    visit signatures_path

    assert_text "Signer 54"
    assert_no_text "Signer 00"

    page.scroll_to :bottom

    assert_text "Signer 00"
  end

  test "clicking load more appends the next page of signatures" do
    visit signatures_path
    assert_no_text "Signer 00"

    click_on "Load more"

    assert_text "Signer 00"
    assert_text "Signer 54"
  end
end
