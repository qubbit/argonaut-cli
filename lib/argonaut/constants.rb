module Argonaut
  class Constants
    SETTINGS_FILE             = "#{Dir.home}/.argonaut.yml".freeze
    PROJECT_GITHUB_URL        = 'https://github.com/qubbit/argonaut-cli'.freeze
    PROJECT_README            = "#{PROJECT_GITHUB_URL}/blob/master/README.md".freeze
    NO_CONFIG_ERROR_MESSAGE   = 'Could not load settings file ~/.argonaut.yml'.freeze
    NO_URL_ROOT_ERROR_MESSAGE = "URL root for Argonaut is not set. Refer to #{PROJECT_README} for instructions on how to set it up.".freeze
    NO_API_TOKEN_ERROR_MESSAGE = "API token for Argonaut is not set. Refer to #{PROJECT_README} for instructions on how to set it up.".freeze
  end
end
