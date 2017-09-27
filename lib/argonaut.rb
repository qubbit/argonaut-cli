require 'argonaut/version'
require 'gateway'

module Argonaut

  class Cli
    attr_reader :gateway

    def initialize(gateway:)
      @gateway = gateway
    end

    def teams
      @geteway.fetch('teams')
    end

    def reservations(team_id)

    end

    def reserve(team_id, app_name, environment_name)
      @gateway.post
    end
  end
end
