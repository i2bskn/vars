class Vars
  class Options
    attr_reader :opts

    module Defaults
      BRANCH      = "master".freeze
      ENV_NAME    = "development".freeze
      REMOTE_NAME = "origin".freeze
      SOURCE_PATH = "config/vars.yml".freeze
      SOURCE_TYPE = :path
    end

    module EnvKeys
      BRANCH      = "TARGET_BRANCH".freeze
      ENV_NAME    = "APP_ENV".freeze
      REMOTE_NAME = "REMOTE_NAME".freeze
    end

    def initialize(opts = {})
      @opts = opts.transform_keys(&:to_sym)
      # Use only when source_type is git.
      @need_fetch = true
    end

    def hash(reload = false)
      @hash = nil if reload
      @hash ||= load_source
    end

    def load_source
      src = YAML.safe_load(ERB.new(raw_source, nil, "-").result(Class.new.__binding__), [], [], true)
      return {} if src.nil?

      src.fetch("default", {}).merge(src.fetch(name.to_s))
    end

    def name
      opts.fetch(:name, ENV.fetch(EnvKeys::ENV_NAME, Defaults::ENV_NAME))
    end

    def repo_path
      return opts.fetch(:repo_path) if opts.key?(:repo_path)
      return nil unless in_repository?

      opts[:repo_path] = capture("git rev-parse --show-toplevel")
    end

    def branch
      return opts.fetch(:branch) if opts.key?(:branch)

      if ENV.key?(EnvKeys::BRANCH)
        opts[:branch] = ENV.fetch(EnvKeys::BRANCH)
      elsif in_repository?
        opts[:branch] = capture("git symbolic-ref --short HEAD")
      else
        Defaults::BRANCH
      end
    end

    def remote_name
      ENV.fetch(EnvKeys::REMOTE_NAME, Defaults::REMOTE_NAME)
    end

    def source_type
      opts.fetch(:source_type, Defaults::SOURCE_TYPE)
    end

    def in_repository?
      opts[:in_repository] = success?("git rev-parse --git-dir") unless opts.key?(:in_repository)
      # Update remote repositories.
      if opts[:in_repository] && @need_fetch
        execute("git fetch #{remote_name}")
        @need_fetch = false
      end

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
          Dir.chdir(repo_path) { capture("git show #{remote_name}/#{branch}:#{path}") }
        else
          raise "unknown source_type: #{source_type}"
        end
      end

      def capture(cmd)
        execute(cmd).first.chomp
        out, error, status = execute(cmd)
        raise error unless status.exitstatus.zero?

        out.chomp
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
