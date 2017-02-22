require 'digest'
require 'tempfile'

module PrSummary
  module Git
    class << self
      def repo
        `basename \`git rev-parse --show-toplevel\``.chomp
      end

      def org
        `git remote get-url origin`.split(":").last.split("/").first.chomp
      end

      def temp_file(name=('a'..'z').to_a.sample(5), &block)
        tmp_file = Tempfile.new(name)
        block.call(tmp_file.path)
        tmp_file.tap(&:rewind).read.chomp.tap do
          tmp_file.close
        end.to_s
      end

      def call(cmd)
        temp_file do |path|
          git_cmd = "git #{cmd} > #{path}"
          puts git_cmd
          system(git_cmd)
        end
      end
    end

    class PullRequest
      attr_reader :repo, :org, :number

      def initialize(org: Git.org, repo: Git.repo, number:)
        @org    = org
        @repo   = repo
        @number = number
      end

      def url
        "https://github.com/#{org}/#{repo}/pull/#{number}"
      end

      def file_url(filename)
        "#{url}/files#diff-#{md5_filename(filename)}"
      end

      def key
        "#{org}_#{repo}_#{number}"
      end

      private

      def md5_filename(filename)
        Digest::MD5.new.update(filename).to_s
      end
    end

    class Diff
      def initialize(diff:)
        @diff = diff
      end

      def shortstat(filename)
        Git.call("diff --shortstat #{diff.branch} #{diff.base} -- #{filename}")
      end

      def name_only
        Git.call("diff --name-only #{diff.branch} #{diff.base}").split("\n")
      end

      private

      attr_reader :diff
    end
  end
end
