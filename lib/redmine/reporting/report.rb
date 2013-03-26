require 'tmpdir'
require 'digest/sha1'
require 'zlib'
require 'httparty'

module Redmine
  module Reporting
    class Report

      def initialize(options)
        @options = options.dup.freeze
      end

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
        options = (config[:http_options] || {}).merge({
          headers: {
            'Content-type' => 'application/json',
            'X-Redmine-API-Key' => config[:api_key]
          }
        })

        if issue_id.nil?
          resp = HTTParty.post("#{config[:base_url]}/issues.json", options.merge({
              body: {
                issue: {
                  subject: @subject.strip,
                  project_id: config[:project],
                  description: @description.strip,
                  tracker_id: config[:tracker],
                  category_id: config[:category]
                }
              }.to_json
            }))

          iid = resp['issue']['id'] rescue nil

          File.open(issue_id_file, File::CREAT|File::TRUNC|File::RDWR, 0600) {|f| f.write(iid.to_s)} unless iid.nil?
        end

        return false if issue_id.nil?

        reference_id = "#{Zlib.crc32(Time.now.to_f.to_s).to_s(16)}#{Zlib.crc32(@subject).to_s(16)}#{Zlib.crc32(@description).to_s(16)}"

        resp = HTTParty.put("#{config[:base_url]}/issues/#{issue_id}.json", options.merge({
            body: {
              issue: {
                notes: "h1. #{reference_id}\n\n#{@notes}".strip
              }
            }.to_json
          }))

        reference_id
      rescue => e
        # TODO ignore
        nil
      end

      private

      def syntax_section(type, title, content=nil, &block)
        @current_var << "#{type}. #{title}\n\n"
        data_to_syntax(content) unless content.nil?
        data_to_syntax(&block) if block_given?
        @current_var << "\n\n"
        nil
      end

      def section(title, content=nil, &block)
        syntax_section('h2', title, content, &block)
      end

      def subsection(title, content=nil, &block)
        syntax_section('h3', title, content, &block)
      end

      def output(content)
        @current_var << "#{content}\n"
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

      def config
        @c ||= Redmine::Reporting.configuration.to_h.merge(@options)
      end

      def issue_hash
        Digest::SHA1.hexdigest([config[:base_url], config[:project], @subject.strip, @description.strip].join('//'))
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
