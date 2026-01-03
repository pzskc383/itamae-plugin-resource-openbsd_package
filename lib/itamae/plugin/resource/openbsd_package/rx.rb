module Itamae
  module Plugin
    module Resource
      module OpenBSDPackage
        module RX
          VERSION_RE = /\A
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
          \Z/x

          FUZZY_RE = /\A
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
            \Z/x
        end
      end
    end
  end
end
