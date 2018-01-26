require_relative './gateway'

module Argonaut

  class Cli
    attr_reader :gateway

    def initialize(gateway:)
      @gateway = gateway
    end

    def teams
      raw_data = @gateway.fetch(path: 'teams')
      raw_data['data']
    end

    # Gets all the reservations for the given team
    def reservations(team_name_or_id)
      @gateway.fetch(path: "teams/#{team_name_or_id}/reservations")
    end

    # Gets list of current user's reservations
    def list_reservations
      @gateway.fetch(path: "list_reservations")
    end

    def clear_reservations
      @gateway.delete(path: "clear_reservations", data: nil)
    end

    def reserve!(env_name, app_name)
      data = { application_name: app_name, environment_name: env_name }
      @gateway.post(path: "reservations", data: data)
    end

    def release!(env_name, app_name)
      data = { application_name: app_name, environment_name: env_name }
      @gateway.delete(path: "reservations", data: data)
    end

    def find_app(app_name)
      data = { application_name: app_name }
      @gateway.fetch(path: "find_application", data: data)
    end

    def initialize_configuration_file
      return false if File.exist? Argonaut::Constants::SETTINGS_FILE

      File.open( Argonaut::Constants::SETTINGS_FILE, "w" ) do |f|
        f.write %q(
# The only required fields needed by the gem to function are api_token and url_root

api_token: YOUR_TOKEN
url_root: https://theargonaut-api.herokuapp.com

# Below are the optional settings to customize output

options:
  colorize_rows: true
  time_format: '%d %b %Y %l:%M %p'
  high_contrast_colors: true
)
      end
      true
    end

  end
end
