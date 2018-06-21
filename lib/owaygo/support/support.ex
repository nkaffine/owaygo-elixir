defmodule Owaygo.Support do
  alias Owaygo.User
  alias Owaygo.Test.VerifyEmail
  alias Owaygo.Location
  alias Owaygo.Location.Type


  #some constants for testing
  @username "nkaffine"
  @fname "Nick"
  @lname "kaffine"
  @email "nicholas.kaffine@gmail.com"
  @gender "male"
  @birthday %{year: 1997, month: 09, day: 21}
  @birthday_string "1997-09-21"
  @user_lat 75.12498129
  @user_lng 118.19248114

  @name "Chicken Lou's"
  @lat 56.012912
  @lng 97.124512

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

  # verifies the email of the given user, returns {:ok, _email_verification} or
  #{:error, error} tuple
  defp verify_email(user) do
    VerifyEmail.call(%{params: %{id: user.id, email: user.email}})
  end


  def create_location(location_param_map) do
    user_param_map = %{username: @username, fname: @fname, lname: @lname,
    email: @email}
    create_location(user_param_map, location_param_map)
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
        {:ok, location} -> {:ok, user, location}
        error -> error
      end
      error -> error
    end
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
end
