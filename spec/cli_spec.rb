require 'spec_helper'

describe Argonaut::Cli do
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

    it 'fetches teams' do
      stub_request(:get, "#{gateway.url_root}/api/teams?token=#{gateway.api_token
      }")
        .to_return(status: 200,
          body: { teams: [ { name: 'epa' }, { name: 'integrations' }] }.to_json
        )
      teams = cli.teams
      expect(teams).to_not be(nil)
    end
  end
end
