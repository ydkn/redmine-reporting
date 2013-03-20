require 'rails'
require 'redmine/reporting/rails/middleware'

module Redmine
  module Reporting
    class Railtie < ::Rails::Railtie
      initializer "redmine_reporting.middleware" do |app|
        app.config.middleware.insert_after('ActionDispatch::DebugExceptions', 'Redmine::Reporting::Rails::Middleware')
      end

      config.after_initialize do
        ActiveSupport.on_load(:action_controller) do
          # Lazily load action_controller methods
          require 'redmine/reporting/rails/controller_methods'
          include Redmine::Reporting::Rails::ControllerMethods
        end
      end
    end
  end
end
