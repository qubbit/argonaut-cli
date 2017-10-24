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

    def reserve!(env_name, app_name)
      data = { application_name: app_name, environment_name: env_name }
      @gateway.post_form_data(path: "reservations", data: data)
    end

    def release!(env_name, app_name)
      data = { application_name: app_name, environment_name: env_name }
      @gateway.delete(path: "teams/#{team_name_or_id}/reservations", data: data)
    end
  end
end
