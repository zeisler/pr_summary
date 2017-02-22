require "yaml"
require "json"
require "pr_summary/file_diff"
require "pr_summary/git"
require "pr_summary/branch_diff"

module PrSummary
  VERSION              = "0.1.0"
  MAX_FILE_NAME_LENGTH = 84

  class << self
    def call(pull_request_number:, branch:, base:)
      pr            = Git::PullRequest.new(number: pull_request_number)
      diff          = BranchDiff.new(base: base, branch: branch)
      markdown_text = create_md(diff, pr)
      save_to_file(markdown_text, pr)
    end

    def save_to_file(markdown_text, pr)
      File.open("#{pr.key}.md", "w") { |file| file.write(markdown_text) }
    end

    def create_md(diff, pr)
      grouped_files(diff).map do |type, files|
        files = files.map do |file|
          link = "[#{file.truncated_name}](#{pr.file_url(file.filename)})"
          "* **#{file.changes_display}** #{link}"
        end.join("\n")
        "## #{type}\n#{files}\n\n"
      end.join("\n")
    end

    def grouped_files(diff)
      grouped               = group_files_by_type(diff)
      sorted_files_in_group = sort_by_insertion_count(diff, grouped)
      listed_order.each_with_object({}) do |type, hash|
        files = sorted_files_in_group[type]
        next if files.nil?
        hash[type] = files
      end
    end

    def sort_by_insertion_count(diff, grouped)
      grouped.each do |type, files|
        grouped[type] = files.map do |file|
          FileDiff.new(filename: file, diff: diff)
        end
        grouped[type] = grouped[type].sort_by { |f| f.insertions || 0 }.reverse
      end
      grouped
    end

    def group_files_by_type(diff)
      Git::Diff.new(diff: diff).name_only.group_by do |filename|
        groups.keys.detect do |group|
          groups[group].any? { |reg| reg =~ filename }
        end
      end
    end

    def listed_order
      [:code, :spec, :fixtures_and_data, :database, :mocks, :other, :documentation]
    end

    def groups
      {
        database:          [/migrate/, /schema\.rb$/, /structure\.sql$/],
        fixtures_and_data: [/.\.yml$/, /.\.json$/, /.\.json\.erb$/],
        spec:              [/._spec\.rb$/, /spec\//],
        mocks:             [/._mock\.rb$/],
        code:              [/.\.rb$/],
        documentation:     [/.\.md$/],
        other:             [/.*/]
      }
    end
  end
end

