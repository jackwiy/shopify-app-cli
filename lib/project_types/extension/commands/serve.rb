# frozen_string_literal: true

module Extension
  module Commands
    class Serve < ExtensionCommand
      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def call(_args, _command_name)
        if ShopifyCli::Shopifolk.check
          ShopifyCli::Tasks::EnsureEnv.call(@ctx, required: [:api_key, :secret, :shop])
          ShopifyCli::Tasks::EnsureDevStore.call(@ctx)
        end

        CLI::UI::Frame.open(@ctx.message('serve.frame_title')) do
          if(ShopifyCli::Shopifolk.check) 
            @ctx.puts("#{construct_url}")
          end
          success = ShopifyCli::JsSystem.call(@ctx, yarn: YARN_SERVE_COMMAND, npm: NPM_SERVE_COMMAND)
          @ctx.abort(@ctx.message('serve.serve_failure_message')) unless success
        end
      end

      def self.help
        <<~HELP
          Serve your extension in a local simulator for development.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}
        HELP
      end

      private 

      def construct_url 
        "https://#{project.env.to_h['SHOP'].to_s}/admin/extension-dev"
      end
    end
  end
end
