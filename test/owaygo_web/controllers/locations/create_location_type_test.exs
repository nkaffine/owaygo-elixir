defmodule OwaygoWeb.Location.TestCreateLocationType do
  use OwaygoWeb.ConnCase

  @typename "restaurant"
  @create %{name: @typename}

  test "return valid output when given valid input" do
    conn = build_conn() |> post("/api/v1/admin/location/type", @create)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["name"] == @typename
  end

  test "throws error when given invalid input" do
    conn = build_conn() |> post("/api/v1/admin/location/type", %{name: "1241512"})
    body = conn |> response(400) |> Poison.decode!
    assert body["name"] == ["has invalid format"]
  end

end
