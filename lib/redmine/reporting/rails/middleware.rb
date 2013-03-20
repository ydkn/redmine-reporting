module Redmine
  module Reporting
    module Rails
      # Rack middleware for Rails applications. Any errors raised by the upstream
      # application will be send to Redmine and re-raised.
      class Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          begin
            response = @app.call(env)
          rescue Exception => exception
            env['redmine_reporting.reference_id'] = redmine_report(env, exception)
            raise exception
          end

          if framework_exception = env['action_dispatch.exception']
            env['redmine_reporting.reference_id'] = redmine_report(env, framework_exception)
          end

          response
        end

        private

        def redmine_report(env, exception)
          return unless desc = env["action_controller.instance"].try(:redmine_reporting_request_data)

          Redmine::Reporting.report(exception.message) do |report|
            report.description do
              section(exception.message) do
                output("<pre>#{exception.backtrace.join("\n")}</pre>")
              end unless exception.nil?
            end
            report.notes do
              section('Parameters') do
                output(desc[:params].collect{|k,v| "* #{k}: #{v}"}.join("\n"))
              end
              section('Session') do
                output(desc[:session].collect{|k,v| "* #{k}: #{v}"}.join("\n"))
              end
            end
          end
        end

        def request_data(env)
          env["action_controller.instance"].try(:redmine_reporting_request_data) || {:rack_env => env}
        end
      end
    end
  end
end
