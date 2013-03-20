module Redmine
  module Reporting
    class Configuration
      attr_accessor :base_url
      attr_accessor :api_key
      attr_accessor :project
      attr_accessor :tracker
      attr_accessor :category
    end
  end
end
