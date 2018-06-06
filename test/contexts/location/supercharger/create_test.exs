defmodule Owaygo.Location.Supercharger.TestCreate do
  use Owaygo.DataCase

  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Location.Type
  alias Owaygo.Location.Supercharger.Create

  @username "nkaffine"
  @fname "nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Wyoming Supercharger"
  @lat 47.1991249112
  @lng 174.91248113

  @stalls 15
  @sc_info_id 12480
  @status "open"
  @open_date "2014-03-20"

  defp create_user() do
    create = %{username: @username, fname: @fname, lname: @lname, email: @email}
    assert {:ok, user} = User.Create.call(%{params: create})
    user.id
  end

  defp verify_email(user_id, email) do
    create = %{id: user_id, email: email}
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: create})
  end

  defp create_type() do
    assert {:ok, _type} = Type.Create.call(%{params: %{name: "supercharger"}})
  end

  defp create() do
    user_id = create_user()
    verify_email(user_id, @email)
    create_type()
    create = %{name: @name, lat: @lat, lng: @lng, stalls: @stalls,
    sc_info_id: @sc_info_id, status: @status, open_date: @open_date,
    discoverer_id: user_id}
    create
  end

  defp create_without_email_verification() do
    user_id = create_user()
    verify_email(user_id, @email)
    create_type()
    create = %{name: @name, lat: @lat, lng: @lng, stalls: @stalls,
    sc_info_id: @sc_info_id, status: @status, open_date: @open_date,
    discoverer_id: user_id}
    create
  end

  defp create_without_type() do
    user_id = create_user()
    verify_email(user_id, @email)
    create = %{name: @name, lat: @lat, lng: @lng, stalls: @stalls,
    sc_info_id: @sc_info_id, status: @status, open_date: @open_date,
    discoverer_id: user_id}
    create
  end

  defp check_success(create) do
    assert {:ok, supercharger} = Create.call(%{params: create})
    assert supercharger.location_id > 0
    assert supercharger.location.name == create.name
    assert supercharger.location.lat == create.lat
    assert supercharger.location.lng == create.lng
    if(create |> Map.has_key?(:stalls)) do
      assert supercharger.stalls == create.stalls
    else
      assert supercharger.stalls == nil
    end
    if(create |> Map.has_key?(:sc_info_id)) do
      assert supercharger.sc_info_id == create.sc_info_id
    else
      assert supercharger.sc_info_id == nil
    end
    if(create |> Map.has_key?(:status)) do
      assert supercharger.status == create.status |> String.downcase
    else
      assert supercharger.status == nil
    end
    if(create |> Map.has_key?(:open_date)) do
      assert supercharger.open_date == create.open_date
    else
      assert supercharger.open_date == nil
    end
    assert supercharger.location.discoverer_id == create.discoverer_id
    assert supercharger.location.claimer_id == nil
    assert supercharger.location.type == "supercharger"
    assert supercharger.location.discovery_date |> to_string == Date.utc_today |> to_string
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "given valid parameters return valid response" do
    check_success(create())
  end

  describe "test when different paramters are missing" do
    test "accept when stalls is missing" do
      check_success(create() |> Map.delete(:stalls))
    end

    test "accept when sc_info_id is missing" do
      check_success(create() |> Map.delete(:sc_info_id))
    end

    test "accept when status is missing" do
      check_success(create() |> Map.delete(:status))
    end

    test "accept when open_date is missing" do
      check_success(create() |> Map.delete(:open_date))
    end

    test "accept when stalls, sc_info_id, status, and open_date are missing" do
      check_success(create() |> Map.delete(:stalls)
      |> Map.delete(:sc_info_id) |> Map.delete(:status)
      |> Map.delete(:open_date))
    end

    test "reject when discoverer_id is not provided" do
      check_error(create() |> Map.delete(:discoverer_id),
      %{discoverer_id: ["can't be blank"]})
    end

    test "name is not provided" do
      check_error(create() |> Map.delete(:name),
      %{name: ["can't be blank"]})
    end

    test "reject when lat is not provided" do
      check_error(create() |> Map.delete(:lat),
      %{lat: ["can't be blank"]})
    end

    test "reject when lng is not provided" do
      check_error(create() |> Map.delete(:lng),
      %{lng: ["can't be blank"]})
    end
  end

  describe "test paramters for locaton specific part" do
    test "accept when user_exists and has verified their email" do
      check_success(create())
    end

    test "reject when user has not verified their email" do
      check_error(create_without_email_verification(),
      %{discoverer_id: ["user has not verified their email"]})
    end

    test "reject when user does not exist" do
      create = create()
      create = create |> Map.put(:discoverer_id, create.discoverer_id + 1)
      check_error(create, %{discoverer_id: ["user does not exist"]})
    end

    test "reject when supercharger type has not been created" do
      check_error(create_without_type(), %{type: ["does not exist"]})
    end

    test "accept when supercharger type has been created" do
      check_success(create())
    end
  end

  describe "check validity of name" do
    test "accept when name is less than 255 characters" do
      check_success(create() |> Map.put(:name, "hasdfjkjasdfinvciqenjasd"))
    end

    test "accept when name is exacly 255 characters" do
      check_success(create() |> Map.put(:name, String.duplicate("a", 255)))
    end

    test "reject when name is more than 255 characters" do
      check_error(create() |> Map.put(:name, String.duplicate("a", 256)),
      %{name: ["should be at most 255 characters"]})
    end
  end

  describe "check validity of lat" do
    test "accept when lat is -90" do
      check_success(create() |> Map.put(:lat, -90))
    end

    test "accept when lat is 90" do
      check_success(create() |> Map.put(:lat, 90))
    end

    test "accept when lat is in between -90 and 90" do
      check_success(create() |> Map.put(:lat, 0))
    end

    test "reject when lat is less than -90" do
      check_error(create() |> Map.put(:lat, -90.124125),
      %{lat: ["must be greater than or equal to -90"]})
    end

    test "reject when lat is greater than 90" do
      check_error(create() |> Map.put(:lat, 90.1325918),
      %{lat: ["must be less than or equal to 90"]})
    end

    test "reject when lat is not a number" do
      check_error(create() |> Map.put(:lat, "jkdfl"),
      %{lat: ["is invalid"]})
    end
  end

  describe "check validity of lng" do
    test "accept when lng is -180" do
      check_success(create() |> Map.put(:lng, -180))
    end

    test "accept when lng is 180" do
      check_success(create() |> Map.put(:lng, 180))
    end

    test "accept when lng is in between -180 and 180" do
      check_success(create() |> Map.put(:lng, 0))
    end

    test "reject when lng is less than -180" do
      check_error(create() |> Map.put(:lng, -180.125125),
      %{lng: ["must be greater than or equal to -180"]})
    end

    test "reject when lng is more than 180" do
      check_error(create() |> Map.put(:lng, 180.01201),
      %{lng: ["must be less than or equal to 180"]})
    end

    test "reject when lng is not a number" do
      check_error(create() |> Map.put(:lng, "jasfja"),
      %{lng: ["is invalid"]})
    end
  end

  describe "check validity of stalls" do
    test "accept when stalls is positive" do
      check_success(create() |> Map.put(:stalls, 8124891))
    end

    test "reject when stalls is negative" do
      check_error(create() |> Map.put(:stalls, -1),
      %{stalls: ["must be greater than 0"]})
    end

    test "reject when stalls is 0" do
      check_error(create() |> Map.put(:stalls, 0),
      %{stalls: ["must be greater than 0"]})
    end
  end

  describe "check validity of sc_info_id" do
    test "accept when sc_info_id is positive" do
      check_success(create() |> Map.put(:sc_info_id, 18125810))
    end

    test "reject when sc_info_id is negative" do
      check_error(create() |> Map.put(:sc_info_id, -1),
      %{sc_info_id: ["must be greater than 0"]})
    end

    test "reject when sc_info_id is 0" do
      check_error(create() |> Map.put(:sc_info_id, 0),
      %{sc_info_id: ["must be greater than 0"]})
    end
  end

  describe "check validity of status" do
    test "accept when status is construction" do
      check_success(create() |> Map.put(:status, "construction"))
    end

    test "accept when status is CONSTRUCTION" do
      check_success(create() |> Map.put(:status, "CONSTRUCTION"))
    end

    test "accept when status is open" do
      check_success(create() |> Map.put(:status, "open"))
    end

    test "accept when status is OPEN" do
      check_success(create() |> Map.put(:status, "OPEN"))
    end

    test "accept when status is permit" do
      check_success(create() |> Map.put(:status, "permit"))
    end

    test "accept when status is PERMIT" do
      check_success(create() |> Map.put(:status, "PERMIT"))
    end

    test "accept when status is closed" do
      check_success(create() |> Map.put(:status, "closed"))
    end

    test "accept when status is CLOSED" do
      check_success(create() |> Map.put(:status, "CLOSED"))
    end

    test "reject when status is something else" do
      check_error(create() |> Map.put(:status, "hasdfjjasdf"),
      %{status: ["is invalid"]})
    end
  end

  describe "check_validity of open_date" do
    test "accept when open date is in the past" do
      check_success(create() |> Map.put(:open_date, Date.utc_today |> Date.add(-1)))
    end

    test "accept when open date is current date" do
      check_success(create() |> Map.put(:open_date, Date.utc_today))
    end

    test "reject when open date is in the future" do
      check_error(create() |> Map.put(:open_date, Date.utc_today |> Date.add(1)),
      %{date: ["open date must today or earlier"]})
    end

    test "reject when date is not a date" do
      check_error(create() |> Map.put(:open_date, "jdkasdg"),
      %{date: ["is invalid"]})
    end
  end


end
