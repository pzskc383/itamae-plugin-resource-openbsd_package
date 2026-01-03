require "itamae/resource/base"

require_relative "openbsd_package/error"
require_relative "openbsd_package/rx"

module Itamae
  module Plugin
    module Resource
      class OpenBSDPackage < Itamae::Resource::Base
        class Error < StandardError; end

        define_attribute :action, default: :install
        define_attribute :name, type: String, default_name: true
        define_attribute :version, type: String
        define_attribute :flavor, type: String
        define_attribute :branch, type: String

        def resource_type
          "openbsd_package"
        end

        def pre_action
          raise Error, "Specify either branch or version" if attributes.version && attributes.branch
        end

        def set_current_attributes
          super
          set_package_info
        end

        def different?
          attrs_to_check = %i[installed branch flavor]
          attrs_to_check.push(:version) unless attributes.version.nil?

          attrs_to_check.each.any? do |attr|
            !current_attributes[attr].nil? &&
              !attributes[attr].nil? &&
              current_attributes[attr] != attributes[attr]
          end
        end

        def action_install
          if !attributes.installed
            run_command(["pkg_add", install_target])
          end
        end

        def action_remove
          if current_attributes.installed
            run_command(["pkg_delete", attributes.name])
          end
        end

        private

        def set_package_info
          fuzzy_check_result = run_command(["pkg_info", "-qze", "#{attributes.name}-*"], error: false)

          if fuzzy_check_result.exit_status > 0
            current_attributes.installed = false
          else
            set_installed_info(fuzzy_check_result)
          end
        end

        def set_installed_info(check_result)
          current_attributes.installed = true

          fm = RX::FUZZY_RE.match(check_result.stdout.lines.first.chomp)

          current_attributes.flavor = fm[:flavor] if fm[:flavor]
          current_attributes.branch = fm[:branch] if fm[:branch]
          current_attributes.version = installed_version(pkg_name)
        end

        def installed_version(pkg_name)
          version_result = run_command(["pkg_info", "-qSe", "#{pkg_name}-*"])

          raise Error, "Invalid version check result!" if version_result.exit_status != 0

          version_line = version_result.stdout.lines.first.chomp
          vm = RX::VERSION_RE.match(version_line)

          raise Error, "Can't find version in version check output!" if !vm || vm[:version].nil?

          vm[:version]
        end

        def install_target
          version = attributes.version or ""
          target = "#{attributes.name}-#{version}-"
          target = "#{pkg_name}#{attributes.flavor}" if attributes.flavor
          target = "#{pkg_name}%#{attributes.branch}" if attributes.branch && attributes.version.nil?
          target
        end
      end
    end
  end
end
