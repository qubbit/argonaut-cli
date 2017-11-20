require_relative './constants'

module Argonaut
  class Settings
    def self.config
      @config ||= read_config
    end

    class << self

      def read_config
        deep_symbolize(YAML.load_file(Argonaut::Constants::SETTINGS_FILE))
      rescue Errno::ENOENT
        { options: {
            colorize_rows: true,
            time_format: '%d %b %Y %l:%M %p'
          }
        }
      end

      def deep_symbolize(obj)
        return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  deep_symbolize(v); memo} if obj.is_a? Hash
        return obj.inject([]){|memo,v| memo << deep_symbolize(v); memo} if obj.is_a? Array
        return obj
      end

    end
  end
end
