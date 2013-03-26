require 'redmine/reporting/version'
require 'redmine/reporting/configuration'
require 'redmine/reporting/report'

module Redmine
  module Reporting

    class << self

      def configure
        yield(configuration)
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def report(subject_or_exception=nil, options={}, &block)
        r = Report.new(options)

        if subject_or_exception.is_a?(Exception)
          r.subject(subject_or_exception.message)
          r.description do
            section("#{subject_or_exception.class}: #{subject_or_exception.message}") do
              output("<pre>#{subject_or_exception.backtrace.join("\n")}</pre>")
            end
          end
        elsif !subject_or_exception.nil?
          r.subject(subject_or_exception)
        end

        block.bind(r).call

        r.commit
      end

    end

  end
end
