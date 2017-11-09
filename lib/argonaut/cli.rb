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

    def reservations(team_name_or_id)
      @gateway.fetch(path: "teams/#{team_name_or_id}/reservations")
    end

    def list_reservations
      @gateway.fetch(path: "list_reservations")
    end

    def clear_reservations
      @gateway.delete(path: "clear_reservations", data: nil)
    end

    def reserve!(env_name, app_name)
      data = { application_name: app_name, environment_name: env_name }
      @gateway.post_form_data(path: "reservations", data: data)
    end

    def release!(env_name, app_name)
      data = { application_name: app_name, environment_name: env_name }
      @gateway.delete(path: "reservations", data: data)
    end

    def find_app(app_name)
      data = { application_name: app_name }
      @gateway.fetch(path: "find_application", data: data)
    end
  end
end
