module ::MItamae
  module Plugin
    module Resource
      class OpenBSDPackage < ::MItamae::Resource::Base
        define_attribute :action, default: :install
        self.available_actions = %i[install remove]

        define_attribute :name, type: String, default_name: true

        define_attribute :version, type: String
        define_attribute :flavor, type: String
        define_attribute :branch, type: String

        def resource_type
          "openbsd_package"
        end
      end
    end
  end
end

# Manually register with correct method name due to mitamae's regex bug
# with consecutive capitals (OpenBSDPackage → open_bsdpackage via buggy regex)
MItamae::RecipeContext.class_eval do
  # Remove the incorrectly-named method mitamae auto-registered
  undef_method(:open_bsdpackage) if method_defined?(:open_bsdpackage)

  # Register with correct name
  define_method(:openbsd_package) do |name, &block|
    @recipe.children << MItamae::Plugin::Resource::OpenBSDPackage.new(name, @recipe, @variables, &block)
  end
end
