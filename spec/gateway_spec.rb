require 'spec_helper'

describe Argonaut::Gateway do
  context 'configuration' do
    let(:configuration_params) do
      { api_token: 'abcd123', url_root: 'whatever.com/api' }
    end

    let(:gateway) { Argonaut::Gateway.new(configuration_params) }

    it 'initializes with proper configuration' do
      expect(gateway.url_root).to eq(configuration_params[:url_root])
      expect(gateway.api_token).to eq(configuration_params[:api_token])
    end

    it 'loads configuration file correctly' do
      allow(Argonaut::Gateway).to receive(:load_config_from_file).and_return({ 'url_root' => 'http://example.com/api', 'api_token' => 'hello' })
      config = Argonaut::Gateway.load_config_from_file
      expect(config['url_root']).to eq('http://example.com/api')
      expect(config['api_token']).to eq('hello')
    end

    it 'loads configuration from environment variables' do
      ENV['ARGONAUT_API_TOKEN'] = 'whatever'
      ENV['ARGONAUT_URL_ROOT'] = 'http://api.com/api'

      expect(ENV['ARGONAUT_API_TOKEN']).to eq('whatever')
      expect(ENV['ARGONAUT_URL_ROOT']).to eq('http://api.com/api')
    end

    it 'loads config from file if invalid settings are passed' do
      configuration_params = { api_token: '', url_root: nil }
      allow_any_instance_of(Argonaut::Gateway).to receive(:config).and_return({ 'api_token' => 'a', 'url_root' => 'b' })
      expect{ Argonaut::Gateway.new(configuration_params) }.not_to raise_error
    end
  end
end
