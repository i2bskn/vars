class Vars < BasicObject
  class Options
    attr_reader :opts

    DEFAULT_NAME   = "default".freeze
    DEFAULT_BRANCH = "master".freeze

    def initialize(opts = {})
      @opts = opts.transform_keys(&:to_sym)
    end

    def name
      opts.fetch(:name, ENV.fetch("APP_ENV", DEFAULT_NAME))
    end

    def repo_path
      return opts.fetch(:repo_path) if opts.key?(:repo_path)

      in_repository? ? `git rev-parse --show-toplevel`.chomp : nil
    end

    def branch
      return opts.fetch(:branch) if opts.key?(:branch)
      return ENV["TARGET_BRANCH"] if ENV.key?("TARGET_BRANCH")

      in_repository? ? `git symbolic-ref --short HEAD`.chomp : DEFAULT_BRANCH
    end

    def source_type
      opts.fetch(:source_type, :path)
    end

    def load_source(path)
      src = YAML.load(ERB.new(raw_source(path), nil, "-").result(binding))
      src.fetch("default", {}).merge(src.fetch(name.to_s))
    end

    def in_repository?
      return @in_repository if instance_variable_defined?(:@in_repository)

      _, _, status = Open3.capture3("git rev-parse --git-dir")
      @in_repository = status.exitstatus.zero?
    end

    private

      def raw_source(path)
        case source_type
        when :path
          File.read(path)
        when :git
          raise "repo_path is nil" if repo_path.nil?
          Dir.chdir(repo_path) { `git show #{branch}:#{path}` }
        else
          raise "Unknown source_type: #{source_type}"
        end
      end
  end
end
