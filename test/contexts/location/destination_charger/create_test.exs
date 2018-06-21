defmodule Owaygo.Location.DestinationCharger.CreateTest do
  use Owaygo.DataCase
  alias Owaygo.Location.DestinationCharger.Create
  alias Owaygo.LocationType
  alias Owaygo.Support

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
  @zip "02115"
  @country "United States"

  @tesla_id "dc12040"

  @special_char_strings ["ajsdf`kasdfk", "ajsdfk@asdfk", "ajsdfk~asdfk",
  "ajsdfk#asdfk", "ajsdfk$asdfk", "ajsdfk%asdfk", "ajsdfk^asdfk",
  "ajsdfk&asdfk", "ajsdfk*asdfk", "ajsdfk(asdfk", "ajsdfk)asdfk",
  "ajsdfk$asdfk", "ajsdfk+asdfk", "ajsdfk=asdfk", "ajsdfk\\asdfk",
  "ajsdfk]asdfk", "ajsdfk[asdfk", "ajsdfk|asdfk", "ajsdfk}asdfk",
  "ajsdfk{asdfk", "ajsdfk<asdfk", "ajsdfk>asdfk", "ajsdfk:asdfk",
  "ajsdfk;asdfk", "ajsdfk'asdfk", "ajsdfk\"asdfk"]

  defp create_type() do
    assert {:ok, _type} = Support.create_location_type("destination_charger")
  end

  defp create() do
    assert {:ok, user} = Support.create_user_verified_email(
    %{username: @username, fname: @fname, lname: @lname, email: @email})
    create_type()
    %{name: @name, lat: @lat, lng: @lng, street: @street, city: @city,
    state: @state, zip: @zip, country: @country, tesla_id: @tesla_id,
    discoverer_id: user.id}
  end

  defp create_without_email_verification() do
    assert {:ok, user} = Support.create_user(
    %{username: @username, fname: @fname, lname: @lname, email: @email})
    create_type()
    %{name: @name, lat: @lat, lng: @lng, street: @street, city: @city,
    state: @state, zip: @zip, country: @country, tesla_id: @tesla_id,
    discoverer_id: user.id}
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
    assert destination_charger.location.discovery_date |> to_string == Date.utc_today |> to_string
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

  test "given valid parameters return valid response" do
    check_success(create())
  end

  describe "test missing paramters" do
    test "accept when tesla_id is missing" do
      check_success(create() |> Map.delete(:tesla_id))
    end

    test "reject when discoverer_id is missing" do
      check_error(create() |> Map.delete(:discoverer_id),
      %{discoverer_id: ["can't be blank"]})
    end

    test "reject when name is missing" do
      check_error(create() |> Map.delete(:name),
      %{name: ["can't be blank"]})
    end

    test "reject when lat is missing" do
      check_error(create() |> Map.delete(:lat),
      %{lat: ["can't be blank"]})
    end

    test "reject when lng is missing" do
      check_error(create() |> Map.delete(:lng),
      %{lng: ["can't be blank"]})
    end

  end

  describe "test missing address parameters" do
    test "accept when country is missing" do
      check_success(create() |> Map.delete(:country))
    end

    test "accept when all address paramters are missing" do
      check_success(create() |> Map.delete(:street)
      |> Map.delete(:city)
      |> Map.delete(:state)
      |> Map.delete(:zip)
      |> Map.delete(:country))
    end

    #the rest of the tests assume that the other parameters are there
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

  describe "test discoverer_id values" do
    test "reject when discoverer_id does not exists" do
      create = create()
      check_error(create |> Map.put(:discoverer_id, create.discoverer_id + 1),
      %{discoverer_id: ["user does not exist"]})
    end

    test "reject when discoverer_id has not verified their email" do
      check_error(create_without_email_verification(),
      %{discoverer_id: ["email has not been verified"]})
    end

    test "reject when discoverer_id is not an integer" do
      check_error(create() |> Map.put(:discoverer_id, "jasfh"),
      %{discoverer_id: ["is invalid"]})
    end

    test "reject when discoverer_id is not positive" do
      check_error(create() |> Map.put(:discoverer_id, -1245),
      %{discoverer_id: ["user does not exist"]})
    end
  end

  describe "test lat values" do
    test "accept when lat is -90" do
      check_success(create() |> Map.put(:lat, -90))
    end

    test "accept when lat is 90" do
      check_success(create() |> Map.put(:lat, 90))
    end

    test "reject when lat is greater than 90" do
      check_error(create() |> Map.put(:lat, 90.12501),
      %{lat: ["must be less than or equal to 90"]})
    end

    test "reject when lat is less than -90" do
      check_error(create() |> Map.put(:lat, -90.1251),
      %{lat: ["must be greater than or equal to -90"]})
    end

    test "reject when lat is not a number" do
      check_error(create() |> Map.put(:lat, "kasfka"),
      %{lat: ["is invalid"]})
    end
  end

  describe "test lng values" do
    test "accept when lng is -180" do
      check_success(create() |> Map.put(:lng, -180))
    end

    test "accept when lng is 180" do
      check_success(create() |> Map.put(:lng, 180))
    end

    test "reject when lng is greater than 180" do
      check_error(create() |> Map.put(:lng, 180.12541),
      %{lng: ["must be less than or equal to 180"]})
    end

    test "reject when lng is less than -180" do
      check_error(create() |> Map.put(:lng, -180.1251),
      %{lng: ["must be greater than or equal to -180"]})
    end

    test "reject when lng is not a number" do
      check_error(create() |> Map.put(:lng, "jsdkdg"),
      %{lng: ["is invalid"]})
    end
  end

  describe "testing validity of tesla_id" do
    test "reject when tesla id does not start with dc" do
      check_error(create() |> Map.put(:tesla_id, "jasfjaaasf"),
      %{tesla_id: ["has invalid format"]})
    end

    test "reject when tesla does not only have numerals after the first two characters" do
      check_error(create() |> Map.put(:tesla_id, "dc81249j101"),
      %{tesla_id: ["has invalid format"]})
    end

    test "reject when tesla_id is longer than 255 characters" do
      check_error(create() |> Map.put(:tesla_id, "dc" <> String.duplicate("1", 255)),
      %{tesla_id: ["should be at most 255 characters"]})
    end

    test "accept when tesla_id is exactly 255 characters" do
      check_success(create() |> Map.put(:tesla_id, "dc" <> String.duplicate("1", 253)))
    end
  end

  describe "test street values" do
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
      @special_char_strings |> Enum.each(fn(value) -> check_error(create
      |> Map.put(:street, "1 " <> value), %{street: ["has invalid format"]})
      end)
    end

    test "reject when street has more than 255 characters" do
      check_error(create() |> Map.put(:street, "123 jasdfk" <> String.duplicate("a", 255)),
      %{street: ["should be at most 255 characters"]})
    end
  end

  describe "test city values" do
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
      @special_char_strings |> Enum.each(fn(value) -> check_error(create
        |> Map.put(:city, value), %{city: ["has invalid format"]})
      end)
    end

    test "reject when city has _" do
      check_error(create() |> Map.put(:city, "jasfko_kasfkk"),
      %{city: ["has invalid format"]})
    end
  end

  describe "test state values" do
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
      @special_char_strings |> Enum.each(fn(value) ->
        check_error(create |> Map.put(:state, value), %{state: ["has invalid format"]})
      end)
    end

    test "reject when state has _" do
      check_error(create() |> Map.put(:state, "jasfkasf_kasfkks"),
      %{state: ["has invalid format"]})
    end
  end

  describe "test zip values" do
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
      special_char_strings = ["f`kfk", "k@asd", "k~asd",
      "k#asd", "k$asd", "k%asd", "k^asd",
      "k&asd", "k*asd", "k(asd", "k)asd",
      "k$asd", "k+asd", "k=asd", "k\\asd",
      "k]asd", "k[asd", "k|asd", "k}asd",
      "k{asd", "k<asd", "k>asd", "k:asd",
      "k;asd", "k'asd", "k\"asd"]
      special_char_strings |> Enum.each(fn(value) ->
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

  describe "test country values" do
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
      @special_char_strings |> Enum.each(fn(value) ->
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
