require_relative './exceptions'
require 'httparty'
require 'uri'

module Argonaut
  class Gateway

    attr_reader :api_token
    attr_reader :url_root

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
        'url_root' => ENV['ARGONAUT_URL_ROOT']
      }

      if ENV['ARGONAUT_API_TOKEN'].nil?
        raise Argonaut::Exceptions::InvalidConfiguration.new 'Could not get API token required to connect to Argonaut'
      end

      if ENV['ARGONAUT_URL_ROOT'].nil?
        raise Argonaut::Exceptions::InvalidConfiguration.new 'Could not get Argonaut URL root'
      end
    end

    def url_from_path(path)
      # ruby's URI module is shitty, but this should suffice
      URI.join(@url_root, "/api/readonly/#{path}?token=#{@api_token}").to_s
    end

    def fetch(path:)
      response = HTTParty.get(url_from_path(path))

      if response.ok?
        JSON(response.body)
      else
        nil
      end
    end

    def post(path:, data:)
      response = HTTParty.post(url_from_path(path), data)

      if response.ok?
        JSON(response.body)
      else
        nil
      end
    end

    def self.load_config_from_file
      YAML.load_file("#{Dir.home}/.argonaut.yml")
    rescue
      nil
    end
  end
end
