# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'argonaut/version'

EMAIL_DOMAIN = 'gmail.com'

Gem::Specification.new do |spec|
  spec.name          = "argonaut-cli"
  spec.version       = Argonaut::VERSION
  spec.authors       = ["Gopal Adhikari"]
  spec.email         = ["nullgeo@#{EMAIL_DOMAIN}"]
  spec.summary       = "Command line tool for Argonaut"
  spec.description   = "This gem lets users manipulate argonaut using the command line interface"
  spec.homepage      = "https://github.com/qubbit/argonaut-cli"
  spec.license       = "MIT"
  spec.post_install_message = %Q{
⚓️  Please follow instructions at #{spec.homepage} to complete the setup.
  }

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency 'webmock', '~> 3.0', '>= 3.0.1'

  spec.add_runtime_dependency 'httparty', '~> 0.15.6'
  spec.add_runtime_dependency 'terminal-table', '~> 1.8', '>= 1.8.0'
end
