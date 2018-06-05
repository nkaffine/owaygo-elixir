defmodule OwaygoWeb.Location.TestCreate do
  use OwaygoWeb.ConnCase

  @lat 89.12481124
  @lng -123.12125125
  @name "Chicken Lou's"
  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email}

  #creates the user with the given parameters and returns the user id
  defp create_user() do
    conn = build_conn() |> post("/api/v1/user", @create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  defp verify_email(id) do
    attrs =  %{email: @email}
    conn = build_conn() |> put(test_verify_email_path(build_conn(), :update, id), attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] == id
    assert body["email"] == @email
    assert body["verification_date"] == Date.utc_today |> to_string
  end

  def create_type(type) do
    create = %{name: type}
    conn = build_conn() |> post("/api/v1/admin/location/type", create)
    body = conn |> response(201) |> Poison.decode!
    body["id"]
  end

  test "given valid parameters accepts and returns the location information" do
    id = create_user()
    verify_email(id)
    attrs = %{lat: @lat, lng: @lng, name: @name, discoverer_id: id}
    conn = build_conn() |> post("/api/v1/location", attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["lat"] == @lat
    assert body["lng"] == @lng
    assert body["name"] == @name
    assert body["discoverer_id"] == id
    assert body["discovery_date"] == Date.utc_today |> to_string
    assert body["claimer_id"] == nil
    assert body["type"] == nil
    #need to add owner and type when they are implemented
  end

  test "given valid parameters and type returns a valid response" do
    id = create_user()
    verify_email(id)
    type = create_type("restaurant")
    attrs = %{lat: @lat, lng: @lng, name: @name, discoverer_id: id, type: "restaurant"}
    conn = build_conn() |> post("/api/v1/location", attrs)
    body = conn |> response(201) |> Poison.decode!
    assert body["id"] |> is_integer
    assert body["id"] > 0
    assert body["lat"] == @lat
    assert body["lng"] == @lng
    assert body["name"] == @name
    assert body["discoverer_id"] == id
    assert body["discovery_date"] == Date.utc_today |> to_string
    assert body["claimer_id"] == nil
    assert body["type"] == type
  end

  test "given invalid paramters throws and error" do
    id = create_user()
    attrs = %{lat: -177.124124152, lng: @lng, name: @name, discoverer_id: id}
    conn = build_conn() |> post("/api/v1/location", attrs)
    body = conn |> response(400) |> Poison.decode!
    assert body["lat"] == ["must be greater than or equal to -90"]
  end
end
