
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "xpose/version"

Gem::Specification.new do |spec|
  spec.name          = "xpose"
  spec.version       = Xpose::VERSION
  spec.authors       = ["Younes SERRAJ"]
  spec.email         = ["younes.serraj@gmail.com"]

  spec.summary       = %q{Helpers to shorten your rails controllers}
  spec.description   = %q{Set of helpers that help shorten your rails controllers by exposing/decorating attributes with inference capabilities}
  spec.homepage      = "https://github.com/yoones/xpose"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
