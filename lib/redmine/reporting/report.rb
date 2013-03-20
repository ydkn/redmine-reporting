require 'tmpdir'
require 'digest/sha1'
require 'zlib'
require 'httparty'

module Redmine
  module Reporting
    class Report

      def subject(s)
        @subject = s
      end

      def description(d=nil, &block)
        @description ||= ''
        @current_var = @description
        data_to_syntax(d, &block)
      end

      def notes(n=nil, &block)
        @notes ||= ''
        @current_var = @notes
        data_to_syntax(n, &block)
      end

      def commit
        config = Redmine::Reporting.configuration

        options = {
          headers: {
            'Content-type' => 'application/json',
            'X-Redmine-API-Key' => config.api_key
          }
        }

        if issue_id.nil?
          resp = HTTParty.post("#{config.base_url}/issues.json", options.merge({
              body: {
                issue: {
                  subject: @subject,
                  project_id: config.project,
                  description: @description,
                  tracker_id: config.tracker,
                  category_id: config.category
                }
              }.to_json
            }))

          issue_id = resp['issue']['id'] rescue nil

          unless issue_id.nil?
            File.open(issue_id_file, File::CREAT|File::TRUNC|File::RDWR, 0600) {|f| f.write(issue_id.to_s) }
          end
        end

        return false if issue_id.nil?

        reference_id = "#{Zlib.crc32(Time.now.to_f.to_s).to_s(16)}#{Zlib.crc32(@subject).to_s(16)}#{Zlib.crc32(@description).to_s(16)}"

        resp = HTTParty.put("#{config.base_url}/issues/#{issue_id}.json", options.merge({
            body: {
              issue: {
                notes: "h1. #{reference_id}\n\n#{@notes}"
              }
            }.to_json
          }))

        reference_id
      rescue Timeout::Error
        nil
      end

      private

      def syntax_section(type, title, content=nil, &block)
        @current_var << "#{type}. #{title}\n\n"
        data_to_syntax(content) unless content.nil?
        data_to_syntax(&block) if block_given?
        nil
      end

      def section(title, content=nil, &block)
        syntax_section('h2', title, content, &block)
      end

      def subsection(title, content=nil, &block)
        syntax_section('h3', title, content, &block)
      end

      def output(content)
        @current_var << content
        nil
      end

      def data_to_syntax(data=nil, &block)
        if block_given?
          out = block.bind(self).call
          @current_var << out if out.is_a?(String)
        else
          @current_var << data
        end
        nil
      end

      def issue_hash
        config = Redmine::Reporting.configuration

        Digest::SHA1.hexdigest([config.base_url, config.project, @subject, @description].join('//'))
      end

      def issue_id_file
        File.join(Dir.tmpdir, "redmine_reporting_#{issue_hash}")
      end

      def issue_id
        if File.exists?(issue_id_file)
          id = File.open(issue_id_file, 'r').read.strip.to_i
          return id if id > 0
        end

        nil
      end

    end
  end
end
