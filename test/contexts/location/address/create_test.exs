defmodule Owaygo.Location.Address.TestCreate do
  use Owaygo.DataCase

  alias Owaygo.User
  alias Owaygo.Location
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Location.Address.Create

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

  defp create_location() do
    user_id = create_user()
    verify_email(user_id, @email)
    create = %{name: @name, lat: @lat, lng: @lng, discoverer_id: user_id}
    assert {:ok, location} = Location.Create.call(%{params: create})
    location.id
  end

  defp verify_email(user_id, email) do
    create = %{id: user_id, email: email}
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: create})
  end

  defp create() do
    location_id = create_location()
    create = %{location_id: location_id, street: @street, city: @city,
    state: @state, zip: @zip, country: @country}
  end

  defp check_success(create) do
    assert {:ok, address} = Create.call(%{params: create})
    assert address.location_id == create.location_id
    assert address.street == create.street
    assert address.city == create.city
    assert address.state == create.state
    assert address.zip == create.zip
    if(create |> Map.has_key?(:country)) do
      assert address.country == create.country
    else
      assert address.country == nil
    end
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "return valid response when given valid paramters" do
    create = create()
    assert {:ok, address} = Create.call(%{params: create})
    assert address.location_id == create.location_id
    assert address.street == @street
    assert address.city == @city
    assert address.state == @state
    assert address.zip == @zip
    assert address.country == @country
  end

  test "reject when missing street" do
    create = create() |> Map.delete(:street)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{street: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when missing city" do
    create = create() |> Map.delete(:city)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{city: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when missing state" do
    create = create() |> Map.delete(:state)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{state: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when missing zip" do
    create = create() |> Map.delete(:zip)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{zip: ["can't be blank"]} == errors_on(changeset)
  end

  test "reject when missing location_id" do
    create = create() |> Map.delete(:location_id)
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{location_id: ["can't be blank"]} == errors_on(changeset)
  end

  test "accept when missing country" do
    create = create() |> Map.delete(:country)
    assert {:ok, address} = Create.call(%{params: create})
    assert address.location_id == location_id
    assert address.street == @street
    assert address.city == @city
    assert address.state == @state
    assert address.zip == @zip
    assert address.country == nil
  end

  test "reject when location does not exist" do
    create = %{location_id: 123, street: @street, city: @city, state: @state,
    zip: @zip, country: @country}
    assert {:error, changeset} = Create.call(%{params: create})
    assert %{location_id: ["does not exist"]} == errors_on(changeset)
  end

  test "reject when location already has address" do
    create = create()
    assert {:ok, address} = Create.call(%{params: create})
    assert address.location_id == create.location_id
    assert address.street == @street
    assert address.city == @city
    assert address.state == @state
    assert address.zip == @zip
    assert address.country == @country
    create = %{location_id: create.location_id, street: "11 Moran Road", city: "Billerica",
    state: "MA", zip: 01862, country: "United States"}
    assert {:error, address} = Create.call(%{params: create})
    assert %{location_id: ["location already has address"]} == errors_on(changeset)
  end

  describe "check that street is valid" do
    test "accept when street has at least one numeral and other alphabetic characters" do
      check_success(create() |> Map.put(:street, "1 jksdfkasdg"))
    end

    test "accept when street has at least one numeral, alphabetic characters and ." do
      check_success(create() |> Map.put(:street, "1 asasdfjjasdgj.kasdgk."))
    end

    test "accept when street has at least one numeral, alphabetic characters and ," do
      check_success(create() |> Map.put(:street, "1 jsdfkasdfk, asdfkakasdg, aksdg")
    end

    test "accept when street has spaces" do
      check_success(create() |> Map.put(:street, "asjdfjasdf jasdfj asdfj"))
    end

    test "accept when street has exactly 255 characters" do
      check_success(create() |> Map.put(:street, "1 " <> String.duplicate("a", 253)))
    end

    test "accept when street has hyphenation" do
      check_success(create() |> Map.put(:street, "123 asdfasdg-jasdgks"))
    end

    test "reject when street doesn't have spaces" do
      check_error(create() |> Map.put(:street, "jasdkas124125dgjasdlkgjasdgk"),
      %{street: ["is invalid"]})
    end

    test "reject when street are no numerals in the street" do
      check_error(create() |> Map.put(:street, "hasdkjasdgkjasd hasdfjg"),
      %{street: ["is invalid"]})
    end

    test "reject when street are no characters in the street" do
      check_error(create() |> Map.put(:street, "192481249124"),
      %{street: ["is invalid"]})
    end

    test "reject when street contains an !" do
      check_error(create() |> Map.put(:street, "123 sdfasdfjhj!"),
      %{street: ["is invalid"]})
    end

    test "reject when street cotains a ?" do
      check_error(create() |> Map.put(:street, "123 jasdfkasdg ?"),
      %{street: ["is invalid"]})
    end

    test "reject when street contains _" do
      check_error(create() |> Map.put(:street, "123 jasdfkjasdfk_asfjka"),
      %{street: ["has invalid format"]})
    end

    test "reject special characters" do
      create = create()
      check_error(create |> Map.put(:street, "123 ajsdf`kasdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk@asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk~asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk#asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk$asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk%asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk^asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk&asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk*asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk(asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk)asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk$asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk+asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk=asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk\\asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk]asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk[asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk|asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk}asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk{asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk<asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk>asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk:asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk;asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk'asdfk"), %{street: ["has invalid format"]})
      check_error(create |> Map.put(:street, "123 ajsdfk\"asdfk"), %{street: ["has invalid format"]})
    end

    test "reject when street has more than 255 characters" do
      check_error(create() |> Map.put(:street, "123 jasdfk" <> String.duplicate("a", 255)),
      %{street: ["has invalid format"]})
    end
  end

  describe "reject when city is invalid" do
    test "accept when city has only alphabetic characters" do
      check_success(create() |> Map.put(:city, "jasdfjasdgjasdgk"))
    end

    test "accept when city has spaces" do
      check_success(create() |> Map.put(:city, "jasdfkk kasdgj"))
    end

    test "reject when city has numerals" do
      check_error(create() |> Map.put(:city, "jasdfkkasdfj12124"),
      %{city: ["has invalid format"]})
    end

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
