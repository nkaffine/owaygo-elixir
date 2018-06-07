defmodule Owaygo.Location.DestinationCharger.CreateTest do
  use Owaygo.DataCase
  alias Owaygo.Location.DestinationCharger.Create
  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owago.Location.Type
  alias Owaygo.LocationType

  @username "nkaffine"
  @fname "nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 74.912481
  @lng 124.9124919

  @street "50 forsyth st."
  @city "Boston"
  @state "MA"
  @zip 02115
  @country "United States"

  @tesla_id "dc12040"

  @special_char_strings ["ajsdf`kasdfk", "ajsdfk@asdfk", "ajsdfk~asdfk",
  "ajsdfk#asdfk", "ajsdfk$asdfk", "ajsdfk%asdfk", "ajsdfk^asdfk",
  "ajsdfk&asdfk", "ajsdfk*asdfk", "ajsdfk(asdfk", "ajsdfk)asdfk",
  "ajsdfk$asdfk", "ajsdfk+asdfk", "ajsdfk=asdfk", "ajsdfk\\asdfk",
  "ajsdfk]asdfk", "ajsdfk[asdfk", "ajsdfk|asdfk", "ajsdfk}asdfk",
  "ajsdfk{asdfk", "ajsdfk<asdfk", "ajsdfk>asdfk", "ajsdfk:asdfk",
  "ajsdfk;asdfk", "ajsdfk'asdfk", "ajsdfk\"asdfk"]

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp verify_email(user_id, email) do
    attrs = %{id: user_id, email: email}
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: attrs})
  end

  defp create_type() do
    assert {:ok, _type} = Type.Create.call(%{name: "destination_charger"})
  end

  defp create() do
    user_id = create_user()
    verify_email(user_id, @email)
    create_type
    create = %{name: @name, lat: @lat, lng: @lng, street: @street, city: @city,
    state: @state, zip: @zip, country: @country, tesla_id: @tesla_id,
    discoverer_id: user_id}
  end

  defp check_if_exists(key, destination_charger, create) do
    if(create |> Map.has_key?(key)) do
      assert destination_charger |> Map.get(key) == create |> Map.get(key)
    else
      assert destination_charger |> Map.get(key) == nil
    end
  end

  defp check_success(create) do
    assert {:ok, destination_charger} = Create.call(%{params: create})
    assert destination_charger.location_id > 0
    assert destination_charger.location.name == create.name
    assert destination_charger.location.lat == create.lat
    assert destination_charger.location.lng == create.lng
    check_if_exists(:street, destination_charger.location.address, create)
    check_if_exists(:city, destination_charger.location.address, create)
    check_if_exists(:state, destination_charger.location.address, create)
    check_if_exists(:zip, destination_charger.location.address, create)
    check_if_exists(:country, destination_charger.location.address, create)
    check_if_exists(:tesla_id, destination_charger, create)
    assert destination_charger.location.claimer_id == nil
    assert destination_charger.location.discovery_date == Date.utc_today |> to_string
    if(Repo.one!(from t in LocationType,
    where: t.name == "destination_charger", select: count(t.id)) == 1) do
      assert destination_charger.location.type == "destination_charger"
    else
      assert destination_charger.location.type == nil
    end
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "given valid parameters return valid response" do
    check_success(create())
  end

  describe "test missing paramters" do
    test "accept when tesla_id is missing" do
      check_success(create() |> Map.delete(:tesla_id))
    end

    test "reject when discoverer_id is missing" do
      check_error(create() |> Map.delete(:discoverer_id),
      %{discoverer_id: ["can't be blank"]})
    end

    test "reject when name is missing" do
      check_error(create() |> Map.delete(:name),
      %{name: ["can't be blank"]})
    end

    test "reject when lat is missing"

    test "reject when lng is missing"

  end

  describe "test missing address parameters" do
    test "accept when country is missing"

    test "accept when all address paramters are missing"

    #the rest of the tests assume that the other parameters are there
    test "reject when street is missing"

    test "reject when city is missing"

    test "reject when state is missing"

    test "reject when zip is missing"
  end

  describe "test discoverer_id values" do
    test "reject when discoverer_id does not exists"

    test "reject when discoverer_id has not verified their email"

    test "reject when discoverer_id is not an integer"

    test "reject when discoverer_id is not positive"
  end

  describe "test lat values" do
    test "accept when lat is -90"

    test "accept when lat is 90"

    test "reject when lat is greater than 90"

    test "reject when lat is less than 90"

    test "reject when lat is not a number"
  end

  describe "test lng values" do
    test "accept when lng is -180"

    test "accept when lng is 180"

    test "reject when lng is greater than 180"

    test "reject when lng is less than -180"
  end

  describe "testing validity of tesla_id" do
    test "reject when tesla id does not start with dc"

    test "reject when tesla does not only have numerals after the first two characters"

    test "reject when tesla_id is longer than 255 characters"

    test "accept when tesla_id is exactly 255 characters"
  end

  describe "test street values" do
    #tuples that contain the string and the reason it is rejected
    @reject_street_strings [{"jasdkas124125dgjasdlkgjasdgk", "no spaces"},
    {"hasdkjasdgkjasd hasdfjg", "no numerals"},
    {"1924812 49124", "no alphabetic characters"},
    {"123 sdfasdfjhj!", "contains !"},
    {"123 jasdfkasdg ?", "contains ?"},
    {"123 jasdfkjasdfk_asfjka", "contains _"},
    {"123 jasdfk" <> String.duplicate("a", 255), "too long"}]

    #tuples that contain the string and what it is testing for acceptance
    @accept_street_strings [{"1 jksdfkasdg", "street is valid"},
    {"1 asasdfjjasdgj.kasdgk.", "has ."},
    {"1 jsdfkasdfk, asdfkakasdg, aksdg", "has ,"},
    {"a124sjdfjasdf jasdfj asdfj", "has spaces"},
    {"1 " <> String.duplicate("a", 253), "exactly 255 characters"},
    {"123 asdfasdg-jasdgks", "has hyphenation"}]

    test "accept when street has at least one numeral and other alphabetic characters"

    test "accept when street has at least one numeral, alphabetic characters and ."

    test "accept when street has at least one numeral, alphabetic characters and ,"

    test "accept when street has spaces"

    test "accept when street has exactly 255 characters"

    test "accept when street has hyphenation"

    test "reject when street doesn't have spaces"

    test "reject when street are no numerals in the street"

    test "reject when street are no characters in the street"

    test "reject when street contains an !"

    test "reject when street cotains a ?"

    test "reject when street contains _"

    test "reject special characters"

    test "reject when street has more than 255 characters"
  end

  describe "test city values" do
    test "accept when city has only alphabetic characters"

    test "accept when city has spaces"

    test "reject when city has numerals"

    test "reject when city has punctuation"

    test "reject when city has special characters"

    test "reject when city has _"
  end

  describe "test state values" do
    test "accpet when state has only alphabetic characters"

    test "accept when state has spaces"

    test "reject when state has numerals"

    test "reject when state has punctuation"

    test "reject when state has special characters"

    test "reject when state has _"
  end

  describe "test zip values" do
    test "accept when zip code is all numerals and 5 digits"

    test "accept when zip code is a numeral string with 5 characters"

    test "reject when zip code is not an integer"

    test "reject when zip code is more than 5 digits"

    test "reject when zip code is negative"

    test "reject when zip code is 5 0's"
  end

  describe "test country values" do
    test "accept when country only has alphabetic characters"

    test "accept when country has spaces"

    test "reject when country has numerals"

    test "reject when country has punctuation"

    test "reject when country has special characters"

    test "reject when country has _"
  end

end
