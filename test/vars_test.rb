require "test_helper"

class VarsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Vars::VERSION
  end
end
