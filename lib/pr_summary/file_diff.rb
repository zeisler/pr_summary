require "pr_summary/git"

module PrSummary
  class FileDiff
    attr_reader :diff, :filename

    def initialize(filename:, diff:)
      @filename = filename
      @diff     = diff
    end

    def insertions
      file_changes[__method__]
    end

    def deletions
      file_changes[__method__]
    end

    def changes_display
      str = ""
      str << "#{insertions}(+)" if insertions
      str << "#{deletions}(-)" if deletions
      str
    end

    def truncated_name
      if filename.length > MAX_FILE_NAME_LENGTH
        "..." + filename[(filename.length-(MAX_FILE_NAME_LENGTH-3))..-1]
      else
        filename
      end
    end

    def md5_file
      Digest::MD5.new.update(filename).to_s
    end

    private

    def file_changes
      @file_changes ||= begin
        text = PrSummary::Git::Diff.new(diff: diff).shortstat(filename)
        {
          insertions: find_number_before(text, "insertion"),
          deletions:  find_number_before(text, "deletion")
        }
      end
    end

    def find_number_before(text, word)
      text.scan(/(\d+) #{word}/)[0][0].to_i rescue nil
    end
  end
end
