require_relative './argonaut/gateway'
require_relative './argonaut/cli'
require_relative './argonaut/settings'
require_relative './argonaut/constants'
require 'date'
require 'pp'

module Argonaut
  def self.exec(options)
    puts "Executing argonaut command with options:\n#{options}" if options.verbose
    gateway = Argonaut::Gateway.new(api_token: nil, url_root: nil)
    interface = Argonaut::Cli.new(gateway: gateway)

    @options = options

    case options.action
    when 'find_app'
      puts interface.find_app(options.application)
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
    when 'clear_reservations'
      status = interface.clear_reservations
    when 'list_reservations'
      data = interface.list_reservations.fetch('data', nil)
      print_reservations_list(data)
    end
  end

  private_class_method

  require 'terminal-table'

  def self.format_date_time(json_time)
    Time.parse(json_time).strftime(@options.time_format || '%d %b %Y %l:%M %p')
  end

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

  def self.print_reservations_list(data)
    rows = []
    data.each do |r|
      rows << [ r['environment'], r['application'], format_date_time(r['reserved_at']) ]
    end

    table = Terminal::Table.new :headings => [ 'Environment', 'Application', 'Reserved At' ], :rows => rows
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

        row = if @options.colorize_rows
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

  @colors               = [122, 141, 153, 163, 172, 178, 183, 186, 223]
  @high_contrast_colors = [122, 141, 153, 163, 172, 178, 183, 186, 223]

  def self.color(index)
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
