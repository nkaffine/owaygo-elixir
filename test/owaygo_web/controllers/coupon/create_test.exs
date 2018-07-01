defmodule OwaygoWeb.Coupon.CreateTest do
  use OwaygoWeb.ConnCase

  alias Owaygo.Support

  defp create() do
    assert {:ok, %{user: _user, location: location}} = Support.create_location_with_owner()
    Support.coupon_param_map() |> Map.put(:location_id, location.id)
  end

  test "return valid response when given valid parameters" do
    create = create()
    conn = build_conn() |> post("/api/v1/owner/coupon", create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["location_id"] == create.location_id
    assert body["description"] == create.description
    assert body["start_date"] == create.start_date
    assert body["end_date"] == create.end_date
    assert body["offered"] == create.offered
    assert body["redemptions"] == 0
    assert body["gender"] == create.gender
    assert body["visited"] == create.visited
    assert body["min_age"] == create.min_age
    assert body["max_age"] == create.max_age
    assert body["percentage_value"] == create.percentage_value
    assert body["dollar_value"] == create.dollar_value
  end

  test "throw error when given invalid paramters" do
    create = create() |> Map.delete(:location_id)
    conn = build_conn() |> post("/api/v1/owner/coupon", create)
    body = conn |> response(400) |> Poison.decode!
    assert body["id"] == nil
    assert body["location_id"] == ["can't be blank"]
    assert body["description"] == nil
    assert body["start_date"] == nil
    assert body["end_date"] == nil
    assert body["offered"] == nil
    assert body["redemptions"] == nil
    assert body["gender"] == nil
    assert body["visited"] == nil
    assert body["min_age"] == nil
    assert body["max_age"] == nil
    assert body["percentage_value"] == nil
    assert body["dollar_value"] == nil
  end
end
