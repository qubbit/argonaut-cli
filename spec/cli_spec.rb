require 'spec_helper'

describe Argonaut::Cli do
  context 'initializes correctly' do
    let(:gateway) { Argonaut::Gateway.new(url_root: nil, api_token: nil) }

    it 'loads the gateway' do
      expect(gateway.api_token).to_be not(nil)
      expect(gateway.url_root).to_be not(nil)
    end
  end

  context 'using cli' do
    let(:gateway) { Argonaut::Gateway.new(url_root: nil, api_token: nil) }
    let(:cli) { Argonaut::Cli.new(gateway) }

    it 'fetches teams' do
      stub_request(:get, "#{gateway.url_root}/{teams}")
        .to_return(status: 200,
          body: { teams: [ { name: 'epa' }, { name: 'integrations' }] }.to_json
        )
      teams = cli.teams
      expect(teams).to_not be(nil)
    end
  end
end
