module Redmine
  module Reporting
    module Rails
      module ControllerMethods

        def self.included(base)
          base.class_eval do
            helper_method :redmine_report_reference_id
          end
        end

        def redmine_reporting_request_data
          {
            :params           => redmine_reporting_filter_hash(params.to_hash),
            :session          => redmine_reporting_filter_hash(session.to_hash),
            :controller       => params[:controller],
            :action           => params[:action],
            :url              => redmine_reporting_request_url
          }
        end

        protected

        # This method should be used for sending manual notifications while you are still
        # inside the controller. Otherwise it works like Redmine::Reporting.report.
        def redmine_report(subject_or_exception, &block)
          unless redmine_reporting_local_request?
            env['redmine_reporting.reference_id'] = Redmine::Reporting.report(subject_or_exception, &block)
          end
        end

        def redmine_report_reference_id
          env['redmine_reporting.reference_id']
        end

        private

        def redmine_reporting_local_request?
          if defined?(::Rails.application.config)
            ::Rails.application.config.consider_all_requests_local || (request.local? && (!request.env["HTTP_X_FORWARDED_FOR"]))
          else
            consider_all_requests_local || (local_request? && (!request.env["HTTP_X_FORWARDED_FOR"]))
          end
        end

        def redmine_reporting_filter_hash(hash)
          return hash if ! hash.is_a?(Hash)

          ActionDispatch::Http::ParameterFilter.new(::Rails.application.config.filter_parameters).filter(hash)
        end

        def redmine_reporting_request_url
          url = "#{request.protocol}#{request.host}"
          url << ":#{request.port}" unless [80, 443].include?(request.port)
          url << request.fullpath

          url
        end

      end
    end
  end
end