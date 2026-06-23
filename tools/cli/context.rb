module KotobaTools
  class CLIContext
    attr_reader :validator

    def initialize(validator)
      @validator = validator
    end

    def shift_human_flag?(argv)
      if argv[0] == "--human"
        argv.shift
        return true
      end
      false
    end
  end
end
