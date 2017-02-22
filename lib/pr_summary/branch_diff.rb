module PrSummary
  class BranchDiff
    attr_reader :base, :branch

    def initialize(base:, branch:)
      @base   = base
      @branch = branch
    end
  end
end
