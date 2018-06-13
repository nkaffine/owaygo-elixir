defmodule Owaygo.Location.Restuarant.CreateTest do
  use Owaygo.DataCase
  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Location.Restuarant.Create

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"

  @name "Chicken Lou's"
  @lat 78.12491124
  @lng 150.091824

  @facebook "www.facebook.com/chicken-lous"
  @twitter "www.twitter.com/chicken-lous"
  @instagram "www.instagram.com/chicken-lous/#"
  @website "www.chicken-lous.com"
  @phone_number "978-555-1234"
  @email "info@chicken-lous.com"

  @street "50 forsyth st."
  @city "Boston"
  @state "MA"
  @zip "02115"
  @country "United States"

  @special_char_strings ["ajsdf`kasdfk", "ajsdfk@asdfk", "ajsdfk~asdfk",
  "ajsdfk#asdfk", "ajsdfk$asdfk", "ajsdfk%asdfk", "ajsdfk^asdfk",
  "ajsdfk&asdfk", "ajsdfk*asdfk", "ajsdfk(asdfk", "ajsdfk)asdfk",
  "ajsdfk$asdfk", "ajsdfk+asdfk", "ajsdfk=asdfk", "ajsdfk\\asdfk",
  "ajsdfk]asdfk", "ajsdfk[asdfk", "ajsdfk|asdfk", "ajsdfk}asdfk",
  "ajsdfk{asdfk", "ajsdfk<asdfk", "ajsdfk>asdfk", "ajsdfk:asdfk",
  "ajsdfk;asdfk", "ajsdfk'asdfk", "ajsdfk\"asdfk"]

  @special_chars ["`", "@", "~",
  "#", "$", "%", "^",
  "&", "*", "(", ")",
  "$", "+", "=", "\\",
  "]", "[", "|", "}",
  "{", "<", ">", ":",
  ";", "'", "\""]

  defp create_user() do
    attrs = %{username: @username, fname: @fname, lname: @lname, email: @email}
    assert {:ok, user} =  User.Create.call(%{params: attrs})
    user.id
  end

  defp verify_email() do
    user_id = create_user()
    assert {:ok, _email_verification} = VerifyEmail.call(%{params: %{id: user_id, email: @email}})
    user_id
  end

  defp create() do
    user_id = verify_email()
    %{name: @name, lat: @lat, lng: @lng, facebook: @facebook, twitter: @twitter,
    instagram: @instagram, website: @website, phone_number: @phone_number,
    email: @email, street: @street, city: @city, state: @state, zip: @zip,
    country: @country, discoverer_id: user_id}
  end

  defp create_without_verification() do
    user_id = create_user()
    %{name: @name, lat: @lat, lng: @lng, facebook: @facebook, twitter: @twitter,
    instagram: @instagram, website: @website, phone_number: @phone_number,
    email: @email, street: @street, city: @city, state: @state, zip: @zip,
    country: @country, discoverer_id: user_id}
  end

  defp check_if_exists(key, restuarant, create) do
    if(create |> Map.has_key?(key)) do
      assert restuarant |> Map.get(key) == create |> Map.get(key)
    else
      assert restuarant |> Map.get(key) == nil
    end
  end

  defp check_success(create) do
    assert {:ok, restuarant} = Create.call(%{params: create})
    assert restuarant.id > 0
    assert restuarant.location.name == create.name
    assert restuarant.location.lat == create.lat
    assert restuarant.location.lng == create.lng
    assert restuarant.facebook == create.facebook
    assert restuarant.twitter == create.twitter
    assert restuarant.instagram == create.instagram
    assert restuarant.website == create.website
    assert restuarant.phone_number == create.phone_number
    assert restuarant.email == create.email
    check_if_exists(:street, restuarant, create)
    check_if_exists(:city, restuarant, create)
    check_if_exists(:state, restuarant, create)
    check_if_exists(:zip, restuarant, create)
    check_if_exists(:country, restuarant, create)
    assert restuarant.location.discoverer_id == create.user_id
    assert restuarant.location.claimer_id == nil
    assert restuarant.location.discovery_date |> to_string == Date.utc_today |> to_string
    if(Repo.one!(from t in LocationType,
    where: t.name == "restuarant", select: count(t.id)) == 1) do
      assert restuarant.location.type == "restuarant"
    else
      assert restuarant.location.type == nil
    end
  end

  defp check_error(create, error) do
    assert {:error, changeset} = Create.call(%{params: create})
    assert error == errors_on(changeset)
  end

  test "given valid parameters returns valid response" do
    check_success(create())
  end

  describe "test missing paramters" do
    test "reject when missing name" do
      check_error(create() |> Map.delete(:name),
      %{name: ["can't be blank"]})
    end

    test "reject when missing lat" do
      check_error(create() |> Map.delete(:lat),
      %{lat: ["can't be blank"]})
    end

    test "reject when missing lng" do
      check_error(create() |> Map.delete(:lng),
      %{lng: ["can't be blank"]})
    end

    test "reject when discoverer_id is missing" do
      check_error(create() |> Map.delete(:discoverer_id),
      %{discoverer_id: ["can't be blank"]})
    end

    test "accept when missing facebook" do
      check_success(create() |> Map.delete(:facebook))
    end

    test "accept when missing twitter" do
      check_success(create() |> Map.delete(:twitter))
    end

    test "accept when missing instagram" do
      check_success(create() |> Map.delete(:instagram))
    end

    test "accept when missing website" do
      check_success(create() |> Map.delete(:website))
    end

    test "accept when missing phone number" do
      check_success(create() |> Map.delete(:phone_number))
    end

    test "accept when missing email" do
      check_success(create() |> Map.delete(:email))
    end

    test "accept when missing country" do
      check_success(create() |> Map.delete(:country))
    end

    test "accept when missing all paramters for address" do
      check_success(create() |> Map.delete(:street)
      |> Map.delete(:city) |> Map.delete(:state)
      |> Map.delete(:zip) |> Map.delete(:country))
    end

    #rest assume that not all paramters for address are missing
    test "reject when missing street" do
      check_error(create() |> Map.delete(:street),
      %{street: ["can't be blank"]})
    end

    test "reject when missing city" do
      check_error(create() |> Map.delete(:city),
      %{city: ["can't be blank"]})
    end

    test "reject when missing state" do
      check_error(create() |> Map.delete(:state),
      %{state: ["can't be blank"]})
    end

    test "reject when missing zip" do
      check_error(create() |> Map.delete(:zip),
      %{zip: ["can't be blank"]})
    end
  end

  describe "test name is valid" do
    test "accept when name is 255 characters" do
      check_success(create() |> Map.put(:name, String.duplicate("a", 255)))
    end

    test "reject when name is more than 255 characters" do
      check_error(create() |> Map.put(:name, String.duplicate("a", 256)),
      %{name: ["should be at most 255 characters"]})
    end
  end

  describe "test lat is valid" do
    test "accept when lat is -90" do
      check_success(create() |> Map.put(:lat, -90))
    end

    test "accept when lat is 90" do
      check_success(create() |> Map.put(:lat, 90))
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

  describe "test lng is valid" do
    test "accept when lng is -180" do
      check_success(create() |> Map.put(:lng, -180))
    end

    test "accept when lng is 180" do
      check_success(create() |> Map.put(:lng, 180))
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

  describe "test dicoverer_id is valid" do
    test "reject when user has not verified their email" do
      check_error(create_without_verification(),
      %{discoverer_id: ["email has not been verified"]})
    end

    test "reject when user does not exist" do
      create = create()
      create = create |> Map.put(:discoverer_id, create.discoverer_id + 1)
      check_error(create, %{discoverer_id: ["user does not exist"]})
    end
  end

  describe "test valid facebook" do
    test "accept when facebook is 255 characters" do
      check_success(create() |> Map.put(:facebook, String.duplicate("a", 255)))
    end

    test "reject when facebook is greater than 255 characters" do
      check_error(create() |> Map.put(:facebook, String.duplicate("a", 256)),
      %{facebook: ["should be at most 255 characters"]})
    end
  end

  describe "test valid twitter" do
    test "accept when twitter is 255 characters" do
      check_success(create() |> Map.put(:twitter, String.duplicate("a", 255)))
    end

    test "reject when twitter is more than 255 characters" do
      check_error(create() |> Map.put(:twitter, String.duplicate("a", 256)),
      %{twitter: ["should be at most 255 characters"]})
    end
  end

  describe "test valid instagram" do
    test "accept when instagram is 255 characters" do
      check_success(create() |> Map.put(:instagram, String.duplicate("a", 255)))
    end

    test "reject when instagram is more than 255 characters" do
      check_error(create() |> Map.put(:instagram, String.duplicate("a", 256)),
      %{instagram: ["should be at most 255 characters"]})
    end

  end

  describe "test valid website" do
    test "accept when wesbite is 255 characters" do
      check_success(create() |> Map.put(:website, String.duplicate("a", 255)))
    end

    test "reject when website is longer than 255 characters" do
      check_error(create() |> Map.put(:website, String.duplicate("a", 256)),
      %{website: ["should be at most 255 characters"]})
    end
  end

  describe "test valid phone number" do
    test "accept when phone is 50 characters" do
      check_success(create() |> Map.put(:phone_number, String.duplicate("0", 50)))
    end

    test "reject when phone is more than 50 characters" do
      check_error(create() |> Map.put(:phone_number, String.duplicate("0", 51)),
      %{phone_number: ["should be at most 50 characters"]})
    end

    test "accept when phone just has numerals" do
      check_success(create() |> Map.put(:phone_number, String.duplicate("0", 5)))
    end

    test "accept when phone has numerals and -" do
      check_success(create() |> Map.put(:phone_number, String.duplicate("0-", 50)))
    end

    test "reject when phone has _" do
      check_error(create() |> Map.put(:phone_number, "0_10124"),
      %{phone_number: ["has invalid format"]})
    end

    test "reject when phone has special characters" do
      create = create()
      @special_chars |> Enum.each(fn(value) ->
        check_error(create |> Map.put(:phone_number, "0912-" <> value <> "-91248"),
        %{phone_number: ["has invalid format"]})
      end)
    end

    test "reject when phone has alphabetic characters" do
      check_error(create() |> Map.put(:phone_number, "9125951kasfk191259"),
      %{phone_number: ["has invalid format"]})
    end

    test "reject when phone has punctuation" do
      create = create()
      error = %{phone_number: ["has invalid format"]}
      check_error(create |> Map.put(:phone_number, "91591295,012500"), error)
      check_error(create |> Map.put(:phone_number, "91591295.012500"), error)
      check_error(create |> Map.put(:phone_number, "91591295!012500"), error)
      check_error(create |> Map.put(:phone_number, "91591295?012500"), error)
      check_error(create |> Map.put(:phone_number, "91591295;012500"), error)
      check_error(create |> Map.put(:phone_number, "9159129:012500"), error)
    end

    test "reject when phone is not a string" do
      check_error(create() |> Map.put(:phone_number, 9012412),
      %{phone_number: ["is invalid"]})
    end
  end

  describe "test valid email" do
    test "accept when email is 5 characters" do
      check_success(create() |> Map.put(:email, "a@d.a"))
    end

    test "reject when email is less than 5 characters" do
      check_error(create() |> Map.put(:email, "@."),
      %{email: ["must be at least 5 characters"]})
    end

    test "accept when email is 255 characters" do
      check_success(create() |> Map.put(:email, String.duplicate("a@a.a", 250)))
    end

    test "reject when email is more than 255 characters" do
      check_error(create() |> Map.put(:email, String.duplicate("a@a.a", 256)),
      %{email: ["should be at most 255 characters"]})
    end

    test "reject when email doesn't have @" do
      check_error(create() |> Map.put(:email, String.duplicate(".", 100)),
      %{email: ["has invalid format"]})
    end

    test "reject when email doesn't have ." do
      check_error(create() |> Map.put(:email, String.duplicate("@", 100)),
      %{email: ["has invalid format"]})
    end
  end

  describe "test valid country" do
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

  describe "test valid street" do
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

  describe "test valid city" do
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

  describe "test valid state" do
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

  describe "test valid zip" do
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
end
