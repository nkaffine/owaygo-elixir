defmodule Owaygo.Location.TestCreate do
  use Owaygo.DataCase

  alias Owaygo.Location.Create
  alias Owaygo.Support

  @lat 75.12501251251
  @lng 175.1259591251
  @name "Chicken Lou's"

  #creates a user and returns the new user's id
  defp create_user() do
    assert {:ok, user} = Support.create_user_verified_email()
    user.id
  end

  defp create() do
    id = create_user()
    %{lat: @lat, lng: @lng, name: @name, discoverer_id: id}
  end

  #Creates a location type and returns the id
  defp create_type(name) do
    {:ok, type} = Support.create_location_type(name)
    type.id
  end

  defp check_location(location, create) do
    assert location.id > 0
    assert location.name == create.name
    assert location.lat == create.lat
    assert location.lng == create.lng
    assert location.discoverer_id == create.discoverer_id
    assert location.claimer_id == nil
    assert location.discovery_date |> to_string == Date.utc_today |> to_string
    location
  end

  defp check_success(create) do
    assert {:ok, location} = Create.call(%{params: create})
    check_location(location, create)
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "return location information when all information is passed" do
    check_success(create())
  end

  #test when there are missing parameters
  test "throw error when no lat is passed" do
    create = create() |> Map.delete(:lat)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{lat: ["can't be blank"]} == errors_on(changeset)
  end

  test "throw error when no lng is passed" do
    create = create() |> Map.delete(:lng)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{lng: ["can't be blank"]} == errors_on(changeset)
  end

  test "throw error when no name is passed" do
    create = create() |> Map.delete(:name)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{name: ["can't be blank"]} == errors_on(changeset)
  end

  test "throw error when no discoverer is passed" do
    create = create() |> Map.delete(:discoverer_id)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{discoverer_id: ["can't be blank"]} == errors_on(changeset)
  end

  #test invalid inputs

  #test lat
  test "throw error when lat is too small" do
    create = create() |> Map.put(:lat, -90.124)
    check_error(create, %{lat: ["must be greater than or equal to -90"]})
  end

  test "throw error when lat is too big" do
    create = create() |> Map.put(:lat, 90.124124)
    check_error(create, %{lat: ["must be less than or equal to 90"]})
  end

  test "accept when lat is exactly -90" do
    create = create() |> Map.put(:lat, -90)
    assert {:ok, location} = Create.call(%{params: create})
    check_location(location, create)
  end

  test "accept when lat is exactly 90" do
    create = create() |> Map.put(:lat, 90)
    check_success(create)
  end

  #test lng
  test "throw error when lng is too small" do
    create = create() |> Map.put(:lng, -180.12512)
    check_error(create, %{lng: ["must be greater than or equal to -180"]})
  end

  test "throw error when lng is too large" do
    create = create() |> Map.put(:lng, 180.125135)
    check_error(create, %{lng: ["must be less than or equal to 180"]})
  end

  test "accept when lng is exactly -180" do
    create = create() |> Map.put(:lng, -180)
    check_success(create)
  end

  test "accept when lng is exactly 180" do
    create = create() |> Map.put(:lng, 180)
    check_success(create)
  end

  #test discoverer
  test "reject when user does not exist" do
    create = %{lat: @lat, lng: @lng, name: @name, discoverer_id: 123}
    check_error(create, %{discoverer_id: ["user does not exist"]})
  end

  #these depend on whether discoverers are the only ones who can discover places
  test "accepts when the user exists but is not a discoverer" do
    user_id = create_user()
    create = %{lat: @lat, lng: @lng, name: @name, discoverer_id: user_id}
    check_success(create)
  end

  #only let people who have verified their email discover things?
  test "reject when user exists but has not verified their email" do
    assert {:ok, user} = Support.create_user()
    create = %{lat: @lat, lng: @lng, name: @name, discoverer_id: user.id}
    check_error(create, %{discoverer_id: ["email has not been verified"]})
  end

  #test name
  test "reject when location has a name longer than 255 characters" do
    create = create() |> Map.put(:name, String.duplicate("a", 256))
    check_error(create, %{name: ["invalid length"]})
  end

  test "accept when location has exactly 255 characters" do
    create = create() |> Map.put(:name, String.duplicate("a", 255))
    check_success(create)
  end

  #should there be any other restrictions on the names of locations (min length,
  #only alphanumerica characters?(would have to include punctuation))

  #need to add test for passing in the type of location it is when being created

  #test ignoring invalid parameters
  test "ingnores when an owner is passed in" do
    create = create() |> Map.put(:owner, 123)
    check_success(create)
  end

  test "ignores when a claimer is passed in" do
    create = create() |> Map.put(:claimer_id, 123)
    check_success(create)
  end

  #testing with location types
  test "passing a valid location type returns the correct location type" do
    type_id = create_type("super_charger")
    create = create() |> Map.put(:type, "super_charger")
    location = check_success(create)
    assert location.type == type_id
  end

  test "passing an invalid location type returns a nil for location type" do
    create = create() |> Map.put(:type, "super_charger")
    location = check_success(create)
    assert location.type == nil
  end

end
