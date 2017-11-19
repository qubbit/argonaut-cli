module Argonaut
  class Settings
    def self.config
      @config ||= read_config
    end

    private_class_method

    def self.read_config
      YAML.load_file("#{Dir.home}/.argonaut.yml").with_indifferent_access
    rescue
      { options: {
          colorize_rows: true,
          time_format: '%d %b %Y %l:%M %p'
        }
      }
    end
  end
end
