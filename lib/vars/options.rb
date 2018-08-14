class Vars < BasicObject
  class Options
    attr_reader :opts

    module Defaults
      BRANCH      = "master".freeze
      ENV_NAME    = "development".freeze
      SOURCE_PATH = "config/vars.yml".freeze
      SOURCE_TYPE = :path
    end

    module EnvKeys
      BRANCH   = "TARGET_BRANCH".freeze
      ENV_NAME = "APP_ENV".freeze
    end

    def initialize(opts = {})
      @opts = opts.transform_keys(&:to_sym)
    end

    def hash(reload = false)
      @hash = nil if reload
      @hash ||= load_source
    end

    def load_source
      src = YAML.safe_load(ERB.new(raw_source, nil, "-").result(BasicObject.new.__binding__), [], [], true)
      src.fetch("default", {}).merge(src.fetch(name.to_s))
    end

    def name
      opts.fetch(:name, ENV.fetch(EnvKeys::ENV_NAME, Defaults::ENV_NAME))
    end

    def repo_path
      case
      when opts.key?(:repo_path)
        opts.fetch(:repo_path)
      when in_repository?
        opts[:repo_path] = capture("git rev-parse --show-toplevel")
      else
        nil
      end
    end

    def branch
      case
      when opts.key?(:branch)
        opts.fetch(:branch)
      when ENV.key?(EnvKeys::BRANCH)
        opts[:branch] = ENV.fetch(EnvKeys::BRANCH)
      when in_repository?
        opts[:branch] = capture("git symbolic-ref --short HEAD")
      else
        Defaults::BRANCH
      end
    end

    def source_type
      opts.fetch(:source_type, Defaults::SOURCE_TYPE)
    end

    def in_repository?
      opts[:in_repository] = success?("git rev-parse --git-dir") unless opts.key?(:in_repository)
      opts.fetch(:in_repository)
    end

    private

      def raw_source
        path = Pathname.new(opts.fetch(:path, Defaults::SOURCE_PATH))
        raise "file not found: #{path}" unless path.exist?

        case source_type
        when :path
          File.read(path)
        when :git
          Dir.chdir(repo_path) { capture("git show #{branch}:#{path}") }
        else
          raise "unknown source_type: #{source_type}"
        end
      end

      def capture(cmd)
        execute(cmd).first.chomp
      end

      def success?(cmd)
        _, _, status = execute(cmd)
        status.exitstatus.zero?
      end

      def execute(cmd)
        Open3.capture3(cmd)
      end
  end
end
