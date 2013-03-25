module Redmine
  module Reporting
    class Configuration
      attr_accessor :base_url
      attr_accessor :api_key
      attr_accessor :project
      attr_accessor :tracker
      attr_accessor :category
      attr_reader :http_options

      def proxy(hostname, port)
        @http_options ||= {}
        @http_options[:http_proxyaddr] = hostname
        @http_options[:http_proxyport] = port
      end

      def proxy_auth(username, password)
        @http_options ||= {}
        @http_options[:http_proxyuser] = username
        @http_options[:http_proxypass] = password
      end
    end
  end
end
