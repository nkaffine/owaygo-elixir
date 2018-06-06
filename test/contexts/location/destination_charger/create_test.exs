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

  test "given valid parameters return valid response"

  describe "test missing paramters" do
    test "accept when tesla_id is missing"

    test "reject when discoverer_id is missing"

    test "reject when name is missing"

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

  end

  describe "test lng values" do

  end

  describe "testing validity of tesla_id" do

  end

  describe "test street values" do

  end

  describe "test city values" do

  end

  describe "test state values" do

  end

  describe "test zip values" do

  end

  describe "test country values" do

  end

end
