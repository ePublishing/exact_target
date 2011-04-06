module ExactTarget
  class Error < Exception

    attr_reader :id, :description

    def initialize(id, description)
      @id = id
      @description = description
    end

    def to_s
      "ExactTarget error ##{id}: #{description}"
    end

  end
end
