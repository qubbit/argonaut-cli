require_relative './constants'
require 'httparty'
require 'uri'

module Argonaut
  class Gateway

    attr_reader :api_token
    attr_reader :url_root

    C = Argonaut::Constants

    # Initializes the HTTP gateway to connect to argonaut's API endpoint
    # The consumer of this API can supply an API token and
    # URL root directly. If any of these are not set, information
    # obtained from ~/.argonaut.yml is used. If ~/.argonaut.yml is
    # not found or cannot be read, the environment variables are
    # used. If everything fails, an error is printed to notify the user
    def initialize(api_token:, url_root:)
      if api_token.nil? || api_token.empty?
        @api_token = config['api_token']
      else
        @api_token = api_token
      end

      if url_root.nil? || url_root.empty?
        @url_root = config['url_root']
      else
        @url_root = url_root
      end

      if @url_root.nil?
        $stderr.puts C::NO_URL_ROOT_ERROR_MESSAGE
        exit(2)
      end

      if @api_token.nil?
        $stderr.puts C::NO_API_TOKEN_ERROR_MESSAGE
        exit(2)
      end
    end

    def config
      return @loaded_config if @loaded_config

      config_from_file = Argonaut::Gateway.load_config_from_file
      if config_from_file
        @loaded_config = config_from_file
        return @loaded_config
      end

      @loaded_config = {
        'api_token' => ENV['ARGONAUT_API_TOKEN'],
        'url_root'  => ENV['ARGONAUT_URL_ROOT']
      }

      if ENV['ARGONAUT_API_TOKEN'].nil? || ENV['ARGONAUT_URL_ROOT'].nil?
        $stderr.puts C::NO_CONFIG_ERROR_MESSAGE
        exit(2)
      end
    end

    def url_from_path(path)
      # ruby's URI module is shitty, but this should suffice
      URI.join(@url_root, "/api/readonly/#{path}?token=#{@api_token}").to_s
    end

    %i{ delete get post }.each do |verb|
      define_method(verb) do |path:, data: nil|
        response = HTTParty.send(verb, url_from_path(path), query: data)

        if response.ok?
          JSON(response.body)
        else
          puts response.body
        end
      end
    end

    # I made fetch happen 😬
    alias fetch get

    def self.load_config_from_file
      YAML.load_file(C::SETTINGS_FILE)
    rescue
      nil
    end
  end
end
