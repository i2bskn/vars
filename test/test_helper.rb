$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "vars"
require "pry"

EXAMPLE_CONFIG_PATH = File.expand_path("example/vars.yml", __dir__)
EXAMPLE_CONFIG_GIT_PATH = "test/example/vars.yml".freeze

require "minitest/autorun"
