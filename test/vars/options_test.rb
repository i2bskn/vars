require "test_helper"

class Vars::OptionsTest < Minitest::Test
  def setup
    @options     = Vars::Options.new(path: EXAMPLE_CONFIG_PATH)
    @git_options = Vars::Options.new(path: EXAMPLE_CONFIG_GIT_PATH, source_type: :git)
  end

  def test_hash
    # assert @options.hash
    # assert @git_options.hash
  end
end
