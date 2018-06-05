defmodule Owaygo.Location.Address.TestCreate do
  use Owaygo.DataCase

  alias Owaygo.User
  alias Owaygo.Location
  alias Owaygo.Test.VerifyEmail

  @username "nkaffine"
  @fname "Nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 56.012912
  @lng 97.124512

  @street "50 forsyth st."
  @city "Boston"
  @state "MA"
  @zip 02115
  @country "United States"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp create_location(user_id) do
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user_id}
    assert {:ok, location} = Location.Create.call(%{params: create})
    location.id
  end

  defp verify_email(user_id, email) do
    create = %{id: user_id, email: email}
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: create})
  end

  test "return valid response when given valid paramters"

  test "reject when missing street"

  test "reject when missing city"

  test "reject when missing state"

  test "reject when missing zip"

  test "accept when missing country"

  test "reject when location does not exist"

  test "reject when location already has address"

  describe "check that street is valid" do
    test "accept when address has at least one numeral and other alphabetic characters"

    test "accept when addres has at least one numeral, alphabetic characters and ."

    test "accept when addres has at least one numeral, alphabetic characters and ,"

    test "accept when address has spaces"

    test "reject when addres doesn't have spaces"

    test "reject when there are no numerals in the street"

    test "reject when there are no characters in the street"

    test "reject when street contains an !"

    test "reject when street cotains a ?"

    test "reject when street contains _"

    test "reject special characters"
  end

  describe "reject when city is invalid" do
    test "accept when city has only alphabetic characters"

    test "accept when city has spaces"

    test "reject when city has numerals"

    test "reject when city has punctuation"

    test "reject when city has special characters"

    test "reject when city has _"
  end

  describe "reject when state is invalid" do
    test "accpet when state has only alphabetic characters"

    test "accept when state has spaces"

    test "reject when state has numerals"

    test "reject when state has punctuation"

    test "reject when state has special characters"

    test "reject when state has _"
  end

  describe "reject when zip code is invalid" do
    test "accept when zip code is all numerals and 5 digits"

    test "reject when zip code is not an integer"

    test "reject when zip code is more than 5 digits"
  end

  describe "reject when country is invalid" do
    test "accept when country only has alphabetic characters"

    test "accept when country has spaces"

    test "reject when country has numerals"

    test "reject when country has punctuation"

    test "reject when country has special characters"

    test "reject when country has _"
  end

end
