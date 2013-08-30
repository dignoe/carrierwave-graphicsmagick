# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/graphicsmagick/version'

Gem::Specification.new do |gem|
  gem.name          = "carrierwave-graphicsmagick"
  gem.version       = CarrierWave::GraphicsMagick::VERSION
  gem.authors       = ["Chad McGimpsey"]
  gem.email         = ["chad.mcgimpsey@gmail.com"]
  gem.description   = "Convenience methods for using CarrierWave with the GraphicsMagick high performance CLI gem."
  gem.summary       = "Convenience methods for using CarrierWave with the GraphicsMagick high performance CLI gem."
  gem.homepage      = "https://github.com/dignoe/carrierwave-graphicsmagick"
  gem.license       = 'MIT'

  gem.add_dependency('graphicsmagick')
  gem.add_dependency('carrierwave')

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
