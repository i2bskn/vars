require "erb"
require "open3"
require "yaml"

require "vars/options"
require "vars/version"

class Vars < BasicObject
  attr_reader :path, :options

  def initialize(path, opts = {})
    @path    = path
    @options = Options.new(opts)
  end

  def [](key)
    hash.fetch(key.to_s, nil)
  end

  def create_file(template_path, output_path)
    ::File.open(output_path, "w") do |f|
      f.write(::ERB.new(::File.read(template_path), nil, "-").result(__binding__))
    end
  end

  def hash
    @hash ||= options.load_source(path)
  end

  private

    def method_missing(name, *args, &block)
      super unless hash.has_key?(name.to_s)

      hash.fetch(name.to_s)
    end

    def respond_to_missing?(name, _include_private = false)
      hash.has_key?(name.to_s)
    end
end
