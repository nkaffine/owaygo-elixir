defmodule Owaygo.Location.TestCreate do
  use Owaygo.DataCase

  alias Owaygo.Location.Create
  alias Owaygo.User.Create

  @username "nkaffine"
  @fname "Nick"
  @lname "Kaffine"
  @email "nicholas.kaffine@gmail.com"
  @create %{username: @username, fname: @fname, lname: @lname, email: @email}
  @lat 75.12501251251
  @lng 175.1259591251
  @name "Chicken Lou's"

  #creates a user and returns the new user's id
  defp create_user() do
    assert {:ok, user} = Create.call(%{params: @create})
    user.id
  end

  test "return location information when all information is passed"

  #test when there are missing parameters
  test "throw error when no lat is passed"

  test "throw error when no lng is passed"

  test "throw error when no name is passed"

  test "throw error when no discoverer is passed"

  #test invalid inputs

  #test lat
  test "throw error when lat is too small"

  test "throw error when lat is too big"

  test "accept when lat is exactly -90"

  test "accept when lat is exaclty 90"

  #test lng
  test "throw error when lng is too small"

  test "throw error when lng is too large"

  test "accept when lng is exactly -180"

  test "accept when lng is exactly 180"

  #test discoverer
  test "reject when user does not exist"

  #these depend on whether discoverers are the only ones who can discover places
  test "reject when user exists but they are not a discoverer"

  #only let people who have verified their email discover things?
  test "reject when user exists and is discoverer but has not verified their email"

  #test name
  test "reject when location has a name longer than 255 characters"

  test "accept when location has exactly 255 characters"

  #should there be any other restrictions on the names of locations (min length,
  #only alphanumerica characters?(would have to include punctuation))

  #need to add test for passing in the type of location it is when being created

  #test ignoring invalid parameters
  test "ingnores when an owner is passed in"

  test "ignores when a claimer is passed in"


end
