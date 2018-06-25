defmodule Owaygo.Location.Supercharger.TestCreate do
  use Owaygo.DataCase
  import Ecto.Query
  alias Owaygo.Location.Supercharger.Create
  alias Owaygo.LocationType
  alias Owaygo.Support

  @name "Wyoming Supercharger"
  @lat 47.1991249112
  @lng 174.91248113

  @stalls 15
  @sc_info_id 12480
  @status "open"
  @open_date "2014-03-20"

  @street "50 forsyth st."
  @city "Boston"
  @state "MA"
  @zip "02115"
  @country "United States"

  defp create_user() do
    assert {:ok, user} = Support.create_user_verified_email()
    user
  end

  defp create_type() do
    assert {:ok, _type} = Support.create_location_type("supercharger")
  end

  defp create() do
    user = create_user()
    create_type()
    %{name: @name, lat: @lat, lng: @lng, stalls: @stalls,
    sc_info_id: @sc_info_id, status: @status, open_date: @open_date,
    discoverer_id: user.id, street: @street, city: @city, state: @state,
    zip: @zip, country: @country}
  end

  defp create_without_email_verification() do
    assert {:ok, user} = Support.create_user()
    create_type()
    create = %{name: @name, lat: @lat, lng: @lng, stalls: @stalls,
    sc_info_id: @sc_info_id, status: @status, open_date: @open_date,
    discoverer_id: user.id, street: @street, city: @city, state: @state,
    zip: @zip, country: @country}
    create
  end

  defp create_without_type() do
    user = create_user()
    create = %{name: @name, lat: @lat, lng: @lng, stalls: @stalls,
    sc_info_id: @sc_info_id, status: @status, open_date: @open_date,
    discoverer_id: user.id, street: @street, city: @city, state: @state,
    zip: @zip, country: @country}
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
      assert supercharger.open_date |> to_string == create.open_date |> to_string
    else
      assert supercharger.open_date == nil
    end
    assert supercharger.location.discoverer_id == create.discoverer_id
    assert supercharger.location.claimer_id == nil
    if(Repo.one!(from t in LocationType, where: t.name == "supercharger", select: count(t.id)) == 0) do
      assert supercharger.location.type == nil
    else
      assert supercharger.location.type == "supercharger"
    end
    assert supercharger.location.discovery_date |> to_string == Date.utc_today |> to_string
    if(create |> Map.has_key?(:street)) do
      assert supercharger.location.address.street == create.street
      assert supercharger.location.address.city == create.city
      assert supercharger.location.address.state == create.state
      assert supercharger.location.address.zip == create.zip
      if(create |> Map.has_key?(:country)) do
        assert supercharger.location.address.country == create.country
      else
        assert supercharger.location.address.country == nil
      end
    end
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

    test "accept when country is missing" do
      check_success(create() |> Map.delete(:country))
    end

    test "accept when all address params are nil" do
      check_success(create() |> Map.delete(:street)
      |> Map.delete(:city)
      |> Map.delete(:state)
      |> Map.delete(:zip)
      |> Map.delete(:country))
    end

    test "reject when street is missing" do
      check_error(create() |> Map.delete(:street),
      %{street: ["can't be blank"]})
    end

    test "reject when city is missing" do
      check_error(create() |> Map.delete(:city),
      %{city: ["can't be blank"]})
    end

    test "reject when state is missing" do
      check_error(create() |> Map.delete(:state),
      %{state: ["can't be blank"]})
    end

    test "reject when zip is missing" do
      check_error(create() |> Map.delete(:zip),
      %{zip: ["can't be blank"]})
    end
   end

  describe "test paramters for locaton specific part" do
    test "accept when user_exists and has verified their email" do
      check_success(create())
    end

    test "reject when user has not verified their email" do
      check_error(create_without_email_verification(),
      %{discoverer_id: ["email has not been verified"]})
    end

    test "reject when user does not exist" do
      create = create()
      create = create |> Map.put(:discoverer_id, create.discoverer_id + 1)
      check_error(create, %{discoverer_id: ["user does not exist"]})
    end

    test "reject when supercharger type has not been created" do
      check_success(create_without_type())
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
      %{name: ["invalid length"]})
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
      %{open_date: ["must be today or earlier"]})
    end

    test "reject when date is not a date" do
      check_error(create() |> Map.put(:open_date, "jdkasdg"),
      %{open_date: ["is invalid"]})
    end
  end

  describe "check validity of street" do
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
      check_error(create() |> Map.put(:street, "1924812 49124"),
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
      Support.rejected_special_chars("1 ", "", []) |> Enum.each(fn(value) -> check_error(create
      |> Map.put(:street, "1 " <> value), %{street: ["has invalid format"]})
      end)
    end

    test "reject when street has more than 255 characters" do
      check_error(create() |> Map.put(:street, "123 jasdfk" <> String.duplicate("a", 255)),
      %{street: ["should be at most 255 characters"]})
    end
  end

  describe "check validity of city" do
    test "accept when city has only alphabetic characters" do
      check_success(create() |> Map.put(:city, "jasfkaskasf"))
    end

    test "accept when city has spaces" do
      check_success(create() |> Map.put(:city, "jasfj aslfjasf"))
    end

    test "reject when city has numerals" do
      check_error(create() |> Map.put(:city, "jSDFk9100010"),
      %{city: ["has invalid format"]})
    end

    test "reject when city has punctuation" do
      create = create()
      error = %{city: ["has invalid format"]}
      check_error(create |> Map.put(:city, "jasdfkk!asgasg"), error)
      check_error(create |> Map.put(:city, "jafkkasfj?lasfj"), error)
      check_error(create |> Map.put(:city, "jasfk,kasfja"), error)
      check_error(create |> Map.put(:city, "jasfkk.kasfhkas"), error)
    end

    test "reject when city has special characters" do
      create = create()
      Support.rejected_special_chars("","",[])
      |> Enum.each(fn(value) -> check_error(create
        |> Map.put(:city, value), %{city: ["has invalid format"]})
      end)
    end

    test "reject when city has _" do
      check_error(create() |> Map.put(:city, "jasfko_kasfkk"),
      %{city: ["has invalid format"]})
    end
  end

  describe "check validity of state" do
    test "accept when state has only alphabetic characters" do
      check_success(create() |> Map.put(:state, "jasfkaskasfjaj"))
    end

    test "accept when state has spaces" do
      check_success(create() |> Map.put(:state, "jasfka kasfjfja"))
    end

    test "reject when state has numerals" do
      check_error(create() |> Map.put(:state, "jasfk012040asfj"),
      %{state: ["has invalid format"]})
    end

    test "reject when state has punctuation" do
      create = create()
      error = %{state: ["has invalid format"]}
      check_error(create |> Map.put(:state, "jasfkkasfh!jfhasf"), error)
      check_error(create |> Map.put(:state, "asfjkasfk?jasfkk"), error)
      check_error(create |> Map.put(:state, "kasfk,kasfkk"), error)
      check_error(create |> Map.put(:state, "jaskasf.lasfj"), error)
    end

    test "reject when state has special characters" do
      create = create()
      Support.rejected_special_chars("","",[]) |> Enum.each(fn(value) ->
        check_error(create |> Map.put(:state, value), %{state: ["has invalid format"]})
      end)
    end

    test "reject when state has _" do
      check_error(create() |> Map.put(:state, "jasfkasf_kasfkks"),
      %{state: ["has invalid format"]})
    end
  end

  describe "check validity of zip" do
    test "accept when zip has only 5 numerals" do
      check_success(create() |> Map.put(:zip, "12341"))
    end

    test "reject when zip has less than 5 numerals" do
      check_error(create() |> Map.put(:zip, "1234"),
      %{zip: ["should be 5 characters"]})
    end

    test "reject when zip has more than 5 numerals" do
      check_error(create() |> Map.put(:zip, "123456"),
      %{zip: ["should be 5 characters"]})
    end

    test "reject when zip has alphabetic characters" do
      check_error(create() |> Map.put(:zip, "123ab"),
      %{zip: ["has invalid format"]})
    end

    test "reject whne zip has punctuation" do
      check_error(create() |> Map.put(:zip, "123?1"),
      %{zip: ["has invalid format"]})
    end

    test "reject when zip has special characters" do
      create = create()
      Support.rejected_special_chars("k", "asd", []) |> Enum.each(fn(value) ->
        check_error(create |> Map.put(:zip, value), %{zip: ["has invalid format"]})
      end)
    end

    test "reject when zip has spaces" do
      check_error(create() |> Map.put(:zip, "123 1"), %{zip: ["has invalid format"]})
    end

    test "reject when zip has _" do
      check_error(create() |> Map.put(:zip, "123_1"), %{zip: ["has invalid format"]})
    end

    test "reject when zip is 00000" do
      check_error(create() |> Map.put(:zip, "00000"), %{zip: ["has invalid format"]})
    end

    test "reject when zip is not string" do
      check_error(create() |> Map.put(:zip, 12345), %{zip: ["is invalid"]})
    end
  end

  describe "check validity of country" do
    test "accept when country only has alphabetic characters" do
      check_success(create() |> Map.put(:country, "jfjkasfkkiiq"))
    end

    test "accept when country has spaces" do
      check_success(create() |> Map.put(:country, "jasfj kasfjka"))
    end

    test "reject when country has numerals" do
      check_error(create() |> Map.put(:country, "jasdj1924ka"),
      %{country: ["has invalid format"]})
    end

    test "reject when country has punctuation" do
      create = create()
      error = %{country: ["has invalid format"]}
      check_error(create |> Map.put(:country, "jasfkk!kasfhkasfj"), error)
      check_error(create |> Map.put(:country, "jasfkkasf?asfjhasf"), error)
      check_error(create |> Map.put(:country, "jasfk.klasfjka"), error)
      check_error(create |> Map.put(:country, "jhasfkjka,asfkka"), error)
    end

    test "reject when country has special characters" do
      create = create()
      Support.rejected_special_chars("","",[]) |> Enum.each(fn(value) ->
        check_error(create |> Map.put(:country, value),
        %{country: ["has invalid format"]})
      end)
    end

    test "reject when country has _" do
      check_error(create() |> Map.put(:country, "jasfkkasf_kasfhj"),
      %{country: ["has invalid format"]})
    end
  end
end
