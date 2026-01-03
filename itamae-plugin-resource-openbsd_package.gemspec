require_relative "lib/itamae/plugin/resource/openbsd_package/version"

Gem::Specification.new do |spec|
  spec.name = "itamae-plugin-resource-openbsd_package"

  spec.version = Itamae::Plugin::Resource::OpenBSDPackage::Version::V
  spec.authors = ["Alexander D."]
  spec.email = ["me@pzskc383.net"]

  spec.summary = %q(itamae plugin resource openbsd_package)
  spec.description = "(m)itamae resource plugin for installing/removing packages on OpenBSD"
  spec.homepage = "https://pzskc383.net/code/itamae-plugin-resource-openbsd_package/tree/README.md"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = "https://pzskc383.net/code/itamae-plugin-resource-openbsd_package"
  spec.metadata["changelog_uri"] = "https://pzskc383.net/code/itamae-plugin-resource-openbsd_package/log/"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = "exe"
  spec.require_paths = ["lib"]

  spec.add_dependency "itamae"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "serverspec"
  spec.add_development_dependency "standardrb", "~> 1.0"
end
