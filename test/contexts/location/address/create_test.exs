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
    %{location_id: location_id, street: @street, city: @city,
    state: @state, zip: @zip, country: @country}
  end

  defp check_success(create) do
    assert {:ok, address} = Create.call(%{params: create})
    assert address.location_id == create.location_id
    assert address.street == create.street
    assert address.city == create.city
    assert address.state == create.state
    if(create.zip |> is_bitstring) do
      {zip, _decimal} = Integer.parse(create.zip)
      assert address.zip == zip
    else
      assert address.zip == create.zip
    end
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

  defp check_invalid_value(value, create, key, error) do
    check_error(create |> Map.put(key, value), error)
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
    assert address.location_id == create.location_id
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
    assert {:error, changeset} = Create.call(%{params: create})
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
      check_success(create() |> Map.put(:street, "1 jsdfkasdfk, asdfkakasdg, aksdg"))
    end

    test "accept when street has spaces" do
      check_success(create() |> Map.put(:street, "a124sjdfjasdf jasdfj asdfj"))
    end

    test "accept when street has exactly 255 characters" do
      check_success(create() |> Map.put(:street, "1 " <> String.duplicate("a", 253)))
    end

    test "accept when street has hyphenation" do
      check_success(create() |> Map.put(:street, "123 asdfasdg-jasdgks"))
    end

    test "reject when street doesn't have spaces" do
      check_error(create() |> Map.put(:street, "jasdkas124125dgjasdlkgjasdgk"),
      %{street: ["has invalid format"]})
    end

    test "reject when street are no numerals in the street" do
      check_error(create() |> Map.put(:street, "hasdkjasdgkjasd hasdfjg"),
      %{street: ["has invalid format"]})
    end

    test "reject when street are no characters in the street" do
      check_error(create() |> Map.put(:street, "192481249124"),
      %{street: ["has invalid format"]})
    end

    test "reject when street contains an !" do
      check_error(create() |> Map.put(:street, "123 sdfasdfjhj!"),
      %{street: ["has invalid format"]})
    end

    test "reject when street cotains a ?" do
      check_error(create() |> Map.put(:street, "123 jasdfkasdg ?"),
      %{street: ["has invalid format"]})
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
      %{street: ["should be at most 255 characters"]})
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

    test "reject when city has punctuation" do
      create = create()
      check_error(create |> Map.put(:city, "asdjaasdfhj!"),
      %{city: ["has invalid format"]})
      check_error(create |> Map.put(:city, "jasdfkasdk?"),
      %{city: ["has invalid format"]})
      check_error(create |> Map.put(:city, "kasfjkAsfkj,"),
      %{city: ["has invalid format"]})
      check_error(create |> Map.put(:city, "jafjasdfjasdg."),
      %{city: ["has invalid format"]})
    end

    test "reject when city has special characters" do
      create = create()
      @special_char_strings |> Enum.each(fn(value) -> value |> check_invalid_value(create, :city,
      %{city: ["has invalid format"]}) end)
    end

    test "reject when city has _" do
      create = create()
      check_error(create |> Map.put(:city, "asdfkasdfk_kasdfk"),
      %{city: ["has invalid format"]})
    end
  end

  describe "reject when state is invalid" do
    test "accpet when state has only alphabetic characters" do
      check_success(create() |> Map.put(:state, "jasdfkasdgk"))
    end

    test "accept when state has spaces" do
      check_success(create() |> Map.put(:state, "kasdfk jasdfkk kasdfk"))
    end

    test "reject when state has numerals" do
      check_error(create() |> Map.put(:state, "kasdfkj0124812j"), %{state: ["has invalid format"]})
    end

    test "reject when state has punctuation" do
      create = create()
      error = %{state: ["has invalid format"]}
      check_error(create |> Map.put(:state, "jasdfkasdkf!ksdgk"), error)
      check_error(create |> Map.put(:state, "jasdfkk?asdfkkasd"), error)
      check_error(create |> Map.put(:state, "jasdfkkaskasdf.jkasdfkj"), error)
      check_error(create |> Map.put(:state, "jsadfjaasdfl,jasdfh"), error)
    end

    test "reject when state has special characters" do
      create = create()
      @special_char_strings |> Enum.each(fn(value) -> value |> check_invalid_value(create, :state,
      %{state: ["has invalid format"]}) end)
    end

    test "reject when state has _" do
      check_error(create() |> Map.put(:state, "asdfk_iadsfkj"), %{state: ["has invalid format"]})
    end
  end

  describe "reject when zip code is invalid" do
    test "accept when zip code is all numerals and 5 digits" do
      check_success(create() |> Map.put(:zip, 12801))
    end

    test "accept when zip code is a numeral string with 5 characters" do
      check_success(create() |> Map.put(:zip, "18294"))
    end

    test "reject when zip code is not an integer" do
      check_error(create() |> Map.put(:zip, "139jasdfj"), %{zip: ["is invalid"]})
    end

    test "reject when zip code is more than 5 digits" do
      check_error(create() |> Map.put(:zip, 102401), %{zip: ["must be less than or equal to 99999"]})
    end

    test "reject when zip code is negative" do
      check_error(create() |> Map.put(:zip, -12400), %{zip: ["must be greater than 0"]})
    end

    test "reject when zip code is 5 0's" do
      check_error(create() |> Map.put(:zip, 00000), %{zip: ["must be greater than 0"]})
    end
  end

  describe "reject when country is invalid" do
    test "accept when country only has alphabetic characters" do
      check_success(create() |> Map.put(:country, "jkakasfkjasfkja"))
    end

    test "accept when country has spaces" do
      check_success(create() |> Map.put(:country, "hasdfj jasdfkk"))
    end

    test "reject when country has numerals" do
      check_error(create() |> Map.put(:country, "jasdfjjasd91249129sdf"),
      %{country: ["has invalid format"]})
    end

    test "reject when country has punctuation" do
      create = create()
      error = %{country: ["has invalid format"]}
      check_error(create |> Map.put(:country, "jhasdfjk!jsdfk"), error)
      check_error(create |> Map.put(:country, "jafkasdfk?kasdfj"), error)
      check_error(create |> Map.put(:country, "jasdfkkasdasd,asdfk"), error)
      check_error(create |> Map.put(:country, "asfjj.kjasdfjj"), error)
    end

    test "reject when country has special characters" do
      error = %{country: ["has invalid format"]}
      create = create()
      @special_char_strings |> Enum.each(fn(value) -> value
      |> check_invalid_value(create, :country, error) end)
    end

    test "reject when country has _" do
      check_error(create() |> Map.put(:country, "jasdfkkasd_ksdfjas"),
      %{country: ["has invalid format"]})
    end
  end

end