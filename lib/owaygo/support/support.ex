defmodule Owaygo.Support do
  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Location
  alias Owaygo.Location.Type
  alias Owaygo.Location.Restaurant.Menu.Category


  #some constants for testing
  @username "nkaffine"
  @fname "Nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"
  @gender "male"
  @birthday %{year: 1997, month: 09, day: 21}
  #@birthday_string "1997-09-21"
  @user_lat 75.12498129
  @user_lng 118.19248114

  @name "Chicken Lou's"
  @lat 56.012912
  @lng 97.124512

  @category_name "main"

  @special_chars ["`", "@", "~",
  "#", "$", "%", "^",
  "&", "*", "(", ")",
  "$", "+", "=", "\\",
  "]", "[", "|", "}",
  "{", "<", ">", ":",
  ";", "\""]

  @doc """
  Creates the param map for the default user in testing
  """
  def user_param_map() do
    %{username: @username, fname: @fname, lname: @lname,
    email: @email, gender: @gender, birthday: @birthday, lat: @user_lat,
    lng: @user_lng}
  end

  @doc """
  Creates a user with the given parameters and returns either an {:ok, user} tuple
  or an {:error, error} tuple.
  The fields for user are (* implies required field):
  username*
  fname*
  lname*
  email*
  gender
  birthday
  lat
  lng
  """
  def create_user(param_map) do
    User.Create.call(%{params: param_map})
  end

  @doc """
  Create a user with the default test paramters and returns either {:ok, user} or
  {:error, error}
  """
  def create_user() do
    create_user(user_param_map())
  end

  @doc """
  Creates a user with the given username and email and the default for the rest
  of the parameters. Either returns {:ok, user} or {:error, error}
  """
  def create_user(username, email) do
    create_user(user_param_map()
    |> Map.put(:username, username)
    |> Map.put(:email, email))
  end

  @doc """
  Creates a user whose email has been verified and returns either an {:ok, user}
  tuple of an {:error, error} tuple.
  The field for user are (* implies required filed):
  username*
  fname*
  lname*
  email*
  gender
  birthday
  lat
  lng
  """
  def create_user_verified_email(param_map) do
    case create_user(param_map) do
      {:ok, user} -> case verify_email(user) do
        {:ok, _email_verification} -> {:ok, user}
        error -> error
      end
      error -> error
    end
  end

  @doc """
  Creates a user with the default test parameters whose email has been verified
  either returns {:ok, user} or {:error, error}
  """
  def create_user_verified_email() do
    create_user_verified_email(user_param_map())
  end

  @doc """
  Creates a user whose email has been verified with the given username and email
  but the default for the rest of the parameters. Either returns {:ok, user} or
  {:error, error}
  """
  def create_user_verified_email(username, email) do
    create_user_verified_email(user_param_map()
    |> Map.put(:username, username)
    |> Map.put(:email, email))
  end

  # verifies the email of the given user, returns {:ok, _email_verification} or
  #{:error, error} tuple
  defp verify_email(user) do
    VerifyEmail.call(%{params: %{id: user.id, email: user.email}})
  end

  @doc """
  Creates the location param map for the default test location
  """
  def location_param_map() do
    %{name: @name, lat: @lat, lng: @lng}
  end

  @doc """
  Create a location with the given parameters and creates a user with the
  default testing paramters to be the discoverer for the location. Either
  returns {:ok, %{user: user, location: location}} or {:error, error}
  """
  def create_location(location_param_map) do
    create_location(user_param_map(), location_param_map)
  end

  @doc """
  Creates a user with the user param map and uses the user as the discoverer
  for making the location. Returns either an {:ok, %{user: user, location: location}}
  or an {:error, error} tuple
  The fields for user are (* implies required field):
  username*
  fname*
  lname*
  email*
  gender
  birthday
  lat
  lng

  The fields for location are (* implies required field):
  lat*
  lng*
  name*
  location_type_id
  """
  def create_location(user_param_map, location_param_map) do
    case create_user_verified_email(user_param_map) do
      {:ok, user} -> case make_location(location_param_map
      |> Map.put(:discoverer_id, user.id)) do
        {:ok, location} -> {:ok, %{user: user, location: location}}
        error -> error
      end
      error -> error
    end
  end

  @doc """
  Creates a location with the default testing location and user data as the discoverer
  and returns either {:ok, %{user: user, location: location}} or {:error, error}
  """
  def create_location() do
    create_location(location_param_map())
  end

  # Creates a location with the given parameters. Returns either {:ok, location}
  #or {:error, error} tuple.
  defp make_location(param_map) do
    Location.Create.call(%{params: param_map})
  end

  @doc """
  Creates a location type with the given type name, either returns {:ok, type} or
  {:error, error} tuple
  """
  def create_location_type(type) do
    Type.Create.call(%{params: %{name: type}})
  end

  @doc """
  Creates a menu category with the default test user and the default test category.
  returns either {:ok %{user: user, category: category}} or {:error, error}
  """
  def create_category() do
    create_category(@category_name)
  end

  @doc """
  Creates a menu category with the given category name and the default test user
  information. Returnes either {:ok, %{user: user, category: category}} or
  {:error, error}
  """
  def create_category(category_name) do
    create_category(user_param_map(), category_name)
  end

  @doc """
  Creates a menu category with the given user_param_map and the menu category name.
  Returns either {:ok, %{user: user, category: category}} or {:error, error}
  """
  def create_category(user_param_map, category_name) do
    case create_user(user_param_map) do
      {:ok, user} -> case Category.Create.call(%{params:
      %{name: category_name, user_id: user.id}}) do
        {:ok, category} -> {:ok, %{user: user, category: category}}
        error -> error
      end
      error -> error
    end
  end

  @doc """
  Creates an array of special character strings with each having the given
  prefix and suffix and excluding any special characters included in the except
  array.

  Prefix: string
  Suffix: string
  except: array of string
  """
  def rejected_special_chars(prefix, suffix, except) do
    special_chars = @special_chars |> Enum.filter(fn(value) ->
      not Enum.member?(except, value)
    end)
    special_chars |> Enum.map(fn(value) ->
      prefix <> value <> suffix
    end)
  end

  @doc """
  Creates an array of special character strings with each having the given
  prefix and suffix and including any special character included in the include.

  Prefix: string
  Suffix: string
  include: array of string
  """
  def accept_special_chars(prefix, suffix, include) do
    special_chars = @special_chars |> Enum.filter(fn(value) ->
      Enum.member?(include, value)
    end)
    special_chars |> Enum.map(fn(value) ->
      prefix <> value <> suffix
    end)
  end
end
