require "erb"
require "open3"
require "pathname"
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

  def resolve_templates(template_path, output_path, excludes: [])
    template_path = ::Pathname.new(template_path)
    output_path   = ::Pathname.new(output_path)
    excludes      = excludes.map(&:to_s)
    template_path.glob("**/*").each do |template_file|
      next if template_file.directory?

      filename = template_file.basename(".erb")
      next unless ([filename.to_s, template_file.basename.to_s] & excludes).empty?

      create_file(
        template_file,
        output_path.join(template_file.dirname.join(filename).relative_path_from(template_path)),
      )
    end
  end

  def create_file(template_file, output_file)
    ::File.open(output_file, "w") do |f|
      f.write(::ERB.new(::File.read(template_file), nil, "-").result(__binding__))
    end
  end

  def hash
    @hash ||= options.load_source(path)
  end

  private

    def method_missing(name, *args, &block)
      super unless hash.key?(name.to_s)

      hash.fetch(name.to_s)
    end

    def respond_to_missing?(name, _include_private = false)
      hash.key?(name.to_s)
    end
end
