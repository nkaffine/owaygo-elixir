defmodule Owaygo.User.UpdateUserInfoTest do
  use Owaygo.DataCase

  alias Owaygo.User.Create

  @valid_username "nkaffine"
  @valid_fname "Nick"
  @valid_lname "Kaffine"
  @valid_email "nicholas.kaffine@gmail.com"
  @valid_gender "male"
  @valid_birthday "1997-09-21"

  @valid_create %{username: @valid_username, fname: @valid_fname,
  lname: @valid_lname, email: @valid_email, gender: @valid_gender,
  birthday: @valid_birthday}

  @fname "Nicholas"
  @lname "Caffeine"
  @gender "other"
  @lat 79.124125
  @lng 101.12451124

  # defp create_user() do
  #   {:ok, user} = Create.call(%{params: @valid_create})
  #   user.id
  # end

  defp create_user(create_statement) do
    {:ok, user} = Create.call(%{params: create_statement})
    user.id
  end

  defp test_success(create_params, update_params) do
    id = create_user(create_params)
    update_params = update_params |> Map.put(:id, id)
    assert {:ok, user} = Create.update(%{params: update_params})
    assert user.id == id
    assert user.username == create_params.username
    assert user.email == create_params.email
    if(update_params |> Map.has_key?(:fname)) do
      assert user.fname == update_params.fname
    else
      assert user.fname == create_params.fname
    end
    if(update_params |> Map.has_key?(:lname)) do
      assert user.lname == update_params.lname
    else
      assert user.lname == create_params.lname
    end
    cond do
      (update_params |> Map.has_key?(:gender)) -> assert user.gender == update_params.gender |> String.downcase
      (create_params |> Map.has_key?(:gender)) -> assert user.gender == create_params.gender |> String.downcase
      true -> assert user.gender == nil
    end
    cond do
      (update_params |> Map.has_key?(:recent_lat)) -> assert user.recent_lat == update_params.recent_lat
      (create_params |> Map.has_key?(:recent_lat)) -> assert user.recent_lat == create_params.recent_lat
      true -> assert user.recent_lat == nil
    end
    cond do
      (update_params |> Map.has_key?(:recent_lng)) -> assert user.recent_lng == update_params.recent_lng
      (create_params |> Map.has_key?(:recent_lng)) -> assert user.recent_lng == create_params.recent_lng
      true -> assert user.recent_lng == nil
    end
  end

  defp test_failure(create_params, update_params, exepected_error) do
    id = create_user(create_params)
    update_params = update_params |> Map.put(:id, id)
    assert {:error, changeset} = Create.update(%{params: update_params})
    refute changeset.valid?
    assert exepected_error == errors_on(changeset)
  end

  test "test accept update and reflect update with all valid input" do
    attrs = %{fname: @fname, lname: @lname, gender: @gender,
    recent_lat: @lat, recent_lng: @lng}
    test_success(@valid_create, attrs)
  end

  # Test all different edge cases for lat

  test "accept when lat is between -90 and 90" do
    attrs = %{recent_lat: @lat, recent_lng: @lng}
    test_success(@valid_create, attrs)
  end

  test "accept when lat is excalty 90" do
    attrs = %{recent_lat: 90, recent_lng: @lng}
    test_success(@valid_create, attrs)
  end

  test "accept when lng is exactly -90" do
    attrs = %{recent_lat: -90, recent_lng: @lng}
    test_success(@valid_create, attrs)
  end

  test "reject when lat is greater than 90" do
    attrs = %{recent_lat: 90.1241251, recent_lng: @lng}
    exepected_error = %{recent_lat: ["invalid latitude"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  test "reject when lat is less than 90" do
    attrs = %{recent_lat: -90.12512, recent_lng: @lng}
    exepected_error = %{recent_lat: ["invalid latitude"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  # Test all different edge cases for lng

  test "accept when lng is between -180 and 180" do
    attrs = %{recent_lat: @lat, recent_lng: @lng}
    test_success(@valid_create, attrs)
  end

  test "accept when lng is exactly 180" do
    attrs = %{recent_lat: @lat, recent_lng: 180}
    test_success(@valid_create, attrs)
  end

  test "accept when lng is exacly -180" do
    attrs = %{recent_lat: @lat, recent_lng: -180}
    test_success(@valid_create, attrs)
  end

  test "reject when lng is larger than 180" do
    attrs = %{recent_lat: @lat, recent_lng: 180.1241251}
    exepected_error = %{recent_lng: ["invalid longitude"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  test "reject when lng is less than -180" do
    attrs = %{recent_lat: @lat, recent_lng: -180.125125}
    exepected_error = %{recent_lng: ["invalid longitude"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  # test different edge cases for gender

  test "accept when gender is male" do
    attrs = %{gender: "male"}
    test_success(@valid_create, attrs)
  end

  test "accept when gender is MALE" do
    attrs = %{gender: "MALE"}
    test_success(@valid_create, attrs)
  end

  test "accept when gender is female" do
    attrs = %{gender: "female"}
    test_success(@valid_create, attrs)
  end

  test "accept when gender is FEMALE" do
    attrs = %{gender: "FEMALE"}
    test_success(@valid_create, attrs)
  end

  test "accept when gender is other" do
    attrs = %{gender: "other"}
    test_success(@valid_create, attrs)
  end

  test "accept when gender is OTHER" do
    attrs = %{gender: "OTHER"}
    test_success(@valid_create, attrs)
  end

  test "reject when gender is none of the above" do
    attrs = %{gender: "jasgjas"}
    exepected_error = %{gender: ["is invalid"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  # test that only a full location will be updated

  test "reject if there is a lat but no lng" do
    attrs = %{recent_lat: @lat}
    exepected_error = %{recent_lat: ["no accompanying longitude"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  test "reject if there is a lng but no lat" do
    attrs = %{recent_lng: @lng}
    exepected_error = %{recent_lng: ["no accompanying latitude"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  # test edge cases for legnth of fname and lname

  test "reject when fname is longer than 255 characters" do
    attrs = %{fname: String.duplicate("a", 256)}
    exepected_error = %{fname: ["invalid length"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  test "accept when fname is exacly 255 characters" do
    attrs = %{fname: String.duplicate("a", 255)}
    test_success(@valid_create, attrs)
  end

  test "accept when fname is less than 255 characters" do
    attrs = %{fname: String.duplicate("a", 212)}
    test_success(@valid_create, attrs)
  end

  test "reject when lname is longer than 255 characters" do
    attrs = %{lname: String.duplicate("a", 256)}
    exepected_error = %{lname: ["invalid length"]}
    test_failure(@valid_create, attrs, exepected_error)
  end

  test "accept when lname is exactly 255 characters" do
    attrs = %{lname: String.duplicate("a", 255)}
    test_success(@valid_create, attrs)
  end

  test "accept when lname is less than 255 characters" do
    attrs = %{lname: String.duplicate("a", 212)}
    test_success(@valid_create, attrs)
  end

  defp test_fname_rejects(fname) do
    test_failure(@valid_create, %{fname: fname}, %{fname: ["names can only contain alphabetic characters"]})
  end

  test "reject when fname has numeric chars" do
    test_fname_rejects("124asnSDGfkasncnas")
  end

  test "reject when fname has punctuation" do
    test_fname_rejects("kaAGsfj!afk?kasfk.")
  end

  test "reject when fname has miscelanious characters" do
    test_fname_rejects("asdADSGksdfk@#-$%^&*~~=+)()(*@`)`/'\;:[{}]'")
  end

  defp test_lname_rejects(lname) do
    test_failure(@valid_create, %{lname: lname}, %{lname: ["names can only contain alphabetic characters"]})
  end

  test "reject when lname has numeric chars" do
    test_lname_rejects("124asnfJSDGkasncnas")
  end

  test "reject when lname has punctuation" do
    test_lname_rejects("kasfj!afSDgk?kasfk.")
  end

  test "reject when lname has miscelanious characters" do
    test_lname_rejects("asdfkSDGsdfk@#-$%^&*~~=+)()(*@`)`/'\;:[{}]'")
  end
end
