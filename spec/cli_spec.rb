require 'spec_helper'

describe Argonaut::Cli do
  let(:token) { 'abcdef' }
  let(:url) { 'https://argonaut.ninja' }
  let(:config) { {'api_token' => token, 'url_root' => url } }

  before do
    allow(Argonaut::Gateway).to receive(:load_config_from_file).and_return(config)
  end

  context 'initializes correctly' do
    let(:gateway) { Argonaut::Gateway.new(url_root: nil, api_token: nil) }

    it 'loads the gateway' do
      expect(gateway.api_token).not_to be_nil
      expect(gateway.url_root).not_to be_nil
    end
  end

  context 'using cli' do
    let(:gateway) { Argonaut::Gateway.new(url_root: nil, api_token: nil) }
    let(:cli) { Argonaut::Cli.new(gateway: gateway) }
    let(:env_app) { URI.encode_www_form({ environment_name: 'pbm1', application_name: 'epamotron' }) }

    before do
      stub_request(:get, "#{gateway.url_root}/api/readonly/teams?token=#{token}")
        .to_return(status: 200, body: fixture('teams.json')
      )
    end

    it 'fetches list of reservations' do
      team_id = cli.teams.first['id']
      s = stub_request(:get, "#{gateway.url_root}/api/readonly/teams/#{team_id}/reservations?token=#{token}")
        .to_return(status: 200, body: fixture('reservations.json')
      )
      data = cli.reservations(team_id)
      expect(s).to have_been_requested
      expect(data).to_not be(nil)
      expect(data.class).to eq(Hash)
      expect(data['applications']).to_not be(nil)
      expect(data['environments']).to_not be(nil)
      expect(data['reservations']).to_not be(nil)
    end

    it 'fetches teams' do
      teams = cli.teams
      expect(teams).to_not be(nil)
      expect(teams.count).to eq(5)
      expect(teams.first['name']).to eq("EPA")
    end

    it 'fetches user reservations' do
      s = stub_request(:get, "#{gateway.url_root}/api/readonly/list_reservations?token=#{token}")
        .to_return(status: 200, body: fixture('user_reservations.json')
      )
      user_reservations = cli.list_reservations
      expect(s).to have_been_requested
      expect(user_reservations).to_not be(nil)
      expect(user_reservations['data']).to_not be(nil)
      expect(user_reservations['data'].first.keys).to eq(['reserved_at', 'environment', 'application'])
    end

    it 'releases env:app' do
      s = stub_request(:delete, "#{gateway.url_root}/api/readonly/reservations?token=#{token}&#{env_app}")
        .to_return(status: 200, body: {}.to_json
      )
      expect { cli.release!('pbm1', 'epamotron') }.to_not raise_error
      expect(s).to have_been_requested
    end

    it 'reserves env:app' do
      s = stub_request(:post, "#{gateway.url_root}/api/readonly/reservations?token=#{token}&#{env_app}")
        .to_return(status: 200, body: {}.to_json
      )
      expect { cli.reserve!('pbm1', 'epamotron') }.to_not raise_error
      expect(s).to have_been_requested
    end

    it 'clears reservations' do
      s = stub_request(:delete, "#{gateway.url_root}/api/readonly/clear_reservations?token=#{token}")
        .to_return(status: 200, body: {}.to_json
      )
      expect { cli.clear_reservations }.to_not raise_error
      expect(s).to have_been_requested
    end

    it 'config exists: does not initialize configuration' do
      expect(File).to receive(:exist?).and_return(true)
      expect(File).to_not receive(:open)

      expect(cli.initialize_configuration_file).to be_falsey
    end

    it 'config missing: initializes configuration' do
      expect(File).to receive(:exist?).and_return(false)
      mock_file = StringIO.new
      expect(File).to receive(:open).with(Argonaut::Constants::SETTINGS_FILE, 'w').and_yield(mock_file)

      expect(cli.initialize_configuration_file).to equal(true)
      ['api_token: YOUR_TOKEN', 'url_root:'].each do |str|
        expect(mock_file.string).to include(str)
      end
    end
  end
end
