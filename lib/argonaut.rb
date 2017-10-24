require_relative './argonaut/gateway'
require_relative './argonaut/cli'

module Argonaut
  def self.exec(options)
    puts options.inspect if options.verbose
    gateway = Argonaut::Gateway.new(api_token: nil, url_root: nil)
    interface = Argonaut::Cli.new(gateway: gateway)

    action = options.action
    @colorize_rows = options.colorize_rows

    case action
    when 'find_app'
      puts interface.find_status_for_app(options.application)
    when 'release'
      env, app = parse_env_app(options.env_app)
      puts interface.release!(env, app)
    when 'reserve'
      env, app = parse_env_app(options.env_app)
      puts interface.reserve!(env, app)
    when 'show_teams'
      all_teams = interface.teams
      print_teams(all_teams)
    when 'show_status'
      status = interface.reservations(options.team)
      print_status(status)
    end
  end

  class Thing
    def ==(other)
      @id == other.id
    end

    def hash
      @id.hash
    end

    def eql?(other)
      self == other
    end
  end

  class Application < Thing
    attr_reader :id, :team_id, :name, :repo, :ping

    def initialize(id:, team_id:, name:, repo:, ping:)
      @id = id
      @team_id = team_id
      @name = name
    end
  end

  class Environment < Thing
    attr_reader :id, :name, :description

    def initialize(id:, name:, description:)
      @id = id
      @name = name
      @description = description
    end
  end

  private_class_method

  require 'terminal-table'

  def self.print_teams(teams_hash)
    rows = []
    rows << ['Id', 'Name', 'Description']
    table = Terminal::Table.new :rows => rows
    table << :separator

    teams_hash.each do |t|
      table.add_row [ t['id'], t['name'], t['description'] ]
    end

    puts table
  end

  def self.print_status(status_hash)
    applications = status_hash['applications']
    environments = status_hash['environments']
    reservations = status_hash['reservations']

    header = [' '] + environments.map {|e| e['name'] }
    rows = []
    rows << header

    table = Terminal::Table.new :rows => rows
    table << :separator

    empty_cells = (1..environments.size).map{|_| " "}
    sentinel = 0

    applications.each do |a|
      cells = empty_cells.dup

      reservations_for_app = find_reservations_for_app(reservations, a)

      if reservations_for_app.empty?
        table.add_row([ a['name'] ] + empty_cells)
      else
        reservations_for_app.each do |r|
          idx = environments.find_index{|e| e['id'] == r['environment']['id'] }
          cells[idx] = r['user']['username']
        end

        row = if @colorize_rows
          colorize_row([ a['name'] ] + cells, sentinel)
        else
          [ a['name'] ] + cells
        end

        table.add_row(row)
        sentinel += 1
      end
    end

    puts table
  end

  @colors = [122, 141, 153, 163, 172, 178, 183, 186, 223]
  def self.color(index)
    # (2 * index + 126) % 159
    @colors[index % @colors.length]
  end

  def self.colorize_row(row, index)
    color = color(index)
    row.map{|cell| "\x1b[38;5;#{color}m#{cell}\e[0m"}
  end

  def self.find_reservations_for_app(reservations, a)
    reservations.select{|r| r['application']['id'] == a['id']}
  end

  def self.parse_env_app(env_app)
    env_app.split(':')
  end
end
