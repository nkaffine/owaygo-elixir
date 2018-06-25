defmodule Owaygo.Location.Hours.CreateTest do
  use Owaygo.DataCase
  
  alias Owaygo.Location.Hours.Create
  alias Owaygo.Support

  @day "monday"
  @hour 13
  @opening true

  defp create_location() do
    assert {:ok, map} = Support.create_location()
    {map.user, map.location}
  end

  defp check_success(create) do
    assert {:ok, hour} = Create.call(%{params: create})
    assert hour.id > 0
    assert hour.location_id == create.location_id
    assert hour.day == create.day |> String.downcase
    assert hour.hour == create.hour
    assert hour.opening == create.opening
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  defp create() do
    {_user, location} = create_location()
    %{location_id: location.id, day: @day, hour: @hour, opening: @opening}
  end

  describe "missing paramters" do
    test "reject when missing location_id" do
      check_error(create() |> Map.delete(:location_id),
      %{location_id: ["can't be blank"]})
    end

    test "reject when missing day" do
      check_error(create() |> Map.delete(:day),
      %{day: ["can't be blank"]})
    end

    test "reject when missing hour" do
      check_error(create() |> Map.delete(:hour),
      %{hour: ["can't be blank"]})
    end

    test "reject when missing opening" do
      check_error(create() |> Map.delete(:opening),
      %{opening: ["can't be blank"]})
    end
  end

  describe "validity of location_id" do
    test "reject when location_id does not exist" do
      create = create()
      check_error(create |> Map.put(:location_id, create.location_id + 1),
      %{location_id: ["does not exist"]})
    end

    test "reject when location_id is not an integer" do
      check_error(create() |> Map.put(:location_id, "ahasjkasf"),
      %{location_id: ["is invalid"]})
    end
  end

  describe "validity of day" do
    test "accept when day is monday" do
      check_success(create() |> Map.put(:day, "monday"))
    end

    test "accept when day is MONDAY" do
      check_success(create() |> Map.put(:day, "MONDAY"))
    end

    test "accept when day is tuesday" do
      check_success(create() |> Map.put(:day, "tuesday"))
    end

    test "accept when day is TUESDAY" do
      check_success(create() |> Map.put(:day, "TUESDAY"))
    end

    test "accept when day is wednesday" do
      check_success(create() |> Map.put(:day, "wednesday"))
    end

    test "accept when day is WEDNESDAY" do
      check_success(create() |> Map.put(:day, "WEDNESDAY"))
    end

    test "accept when day is thursday" do
      check_success(create() |> Map.put(:day, "thursday"))
    end

    test "accept when day is THURSDAY" do
      check_success(create() |> Map.put(:day, "THURSDAY"))
    end

    test "accept when day is friday" do
      check_success(create() |> Map.put(:day, "friday"))
    end

    test "accept when day is FRIDAY" do
      check_success(create() |> Map.put(:day, "FRIDAY"))
    end

    test "accept when day is saturday" do
      check_success(create() |> Map.put(:day, "saturday"))
    end

    test "accept when day is SATURDAY" do
      check_success(create() |> Map.put(:day, "SATURDAY"))
    end

    test "accept when day is sunday" do
      check_success(create() |> Map.put(:day, "sunday"))
    end

    test "accept when day is SUNDAY" do
      check_success(create() |> Map.put(:day, "SUNDAY"))
    end

    test "reject when day is something else" do
      check_error(create() |> Map.put(:day, "viernes"),
      %{day: ["is invalid"]})
    end
  end

  describe "validity of hour" do
    test "reject when hour is equal to 24" do
      check_error(create() |> Map.put(:hour, 24),
      %{hour: ["must be less than 24"]})
    end

    test "reject when hour is greater than 24" do
      check_error(create() |> Map.put(:hour, 25),
      %{hour: ["must be less than 24"]})
    end

    test "reject when hour is less than 0" do
      check_error(create() |> Map.put(:hour, -1),
      %{hour: ["must be greater than or equal to 0"]})
    end

    test "reject when hour is not an float" do
      check_error(create() |> Map.put(:hour, "10:00am"),
      %{hour: ["is invalid"]})
    end

    test "accept decimals" do
      check_success(create() |> Map.put(:hour, 12.5))
    end
  end

  describe "validity of opening" do
    test "reject when opening is not a boolean" do
      check_error(create() |> Map.put(:opening, "jasfja"),
      %{opening: ["is invalid"]})
    end
  end

end
