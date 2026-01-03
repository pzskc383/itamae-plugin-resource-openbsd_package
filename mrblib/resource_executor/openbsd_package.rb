module ::MItamae
  module Plugin
    module ResourceExecutor
      OpenBSDPackageError = Class.new(::RuntimeError)

      class OpenBSDPackage < ::MItamae::ResourceExecutor::Base
        VERSION_RE = %r{\A
          (?<name>
            [a-z0-9-]*[a-z0-9]
          )-
          (?<version>
            [0-9.]+
            (?:(?:rc|alpha|beta|pre|pl|p)[0-9]+)?
          )
          (?<flavor>
            [a-z0-9_-]+
          )?
          ,.*
        \Z}x

        FUZZY_RE = %r{\A
            (?<name>
              [a-z0-9-]+[a-z0-9]
            )--
            (?<flavor>
              [a-z0-9_]+
            )?
            (?<branch>
              (?<=%)
              [a-z0-9_-]+
            )?
          \Z}x

        def apply
          # ::MItamae.logger.debug "Desired: #{desired.inspect}"
          # ::MItamae.logger.debug "Current: #{current.inspect}"

          if desired.installed && !current.installed
            install_package(desired)
          elsif !desired.installed && current.installed
            delete_package(current.name)
          elsif attributes_changed?
            delete_package(current.name)
            install_package(desired)
          end
        end

        private

        def attributes_changed?
          attrs_to_check = %i[branch flavor]
          # we check version only if version specified
          attrs_to_check.push(:version) if desired.version

          attrs_to_check.each do |m|
            if current.send(m) != desired.send(m)
              ::MItamae.logger.debug "#{m} changed! #{current.send(m)} != #{desired.send(m)}"
              return true
            end
          end
          false
        end

        def set_current_attributes(current, _action)
          installed_info = installed_info(attributes.name)

          %i[name installed version branch flavor].each do |k|
            current.send("#{k}=", installed_info[k]) unless installed_info[k].nil?
          end
        end

        def set_desired_attributes(desired, action)
          case action
          when :install
            desired.installed = true
          when :remove
            desired.installed = false
          end
        end

        def installed_info(pkg_name)
          info = { name: pkg_name, installed: false }
          fuzzy_check_result = run_command(["pkg_info", "-qze", "#{pkg_name}-*"], error: false)

          return info if fuzzy_check_result.exit_status > 0

          info[:installed] = true

          fm = FUZZY_RE.match(fuzzy_check_result.stdout.lines.first.chomp)

          info[:flavor] = fm[:flavor] if fm[:flavor]
          info[:branch] = fm[:branch] if fm[:branch]
          info[:version] = get_version(pkg_name)

          info
        rescue StandardError => e
          ::MItamae.logger.error "Error checking installed info: #{e.inspect}"
          info
        end

        def get_version(pkg_name)
          version_result = run_command(["pkg_info", "-qSe", "#{pkg_name}-*"])

          raise OpenBSDPackageError, "Invalid version check result!" if version_result.exit_status != 0

          version_line = version_result.stdout.lines.first.chomp
          vm = VERSION_RE.match(version_line)

          raise OpenBSDPackageError, "Can't find version in version check output!" if !vm || vm[:version].nil?

          vm[:version]
        end

        def delete_package(pkg_name)
          run_command(["pkg_delete", pkg_name])
        end

        def install_package(info)
          raise OpenBSDPackageError, "Specify either branch or version" if info.version && info.branch

          version = info.version or ""
          pkg_name = "#{info.name}-#{version}-"
          pkg_name = "#{pkg_name}#{info.flavor}" if info.flavor
          pkg_name = "#{pkg_name}%#{info.branch}" if info.branch && info.version.nil?

          run_command(["pkg_add", pkg_name])
        end
      end
    end
  end
end
