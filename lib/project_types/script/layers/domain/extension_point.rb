# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ExtensionPoint
        attr_reader :type, :deprecated, :sdks

        def initialize(type, config)
          @type = type
          @deprecated = config["deprecated"] || false
          @sdks = {
            ts: ExtensionPointAssemblyScriptSDK.new(config["assemblyscript"]),
          }
        end

        def deprecated?
          @deprecated
        end
      end

      class ExtensionPointAssemblyScriptSDK
        attr_reader :package, :version, :sdk_version, :toolchain_version

        def initialize(config)
          @package = config["package"]
          @sdk_version = config["sdk-version"]
          @toolchain_version = config["toolchain-version"]
        end
      end
    end
  end
end
