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

  class EmailAddressError < Error
    def initialize(email)
      @email = email
    end
  end

  class BlacklistError < EmailAddressError
    def to_s
      "#{@email} is on the email address blacklist"
    end
  end

  class WhitelistError < EmailAddressError
    def to_s
      "#{@email} is not on the email address whitelist"
    end
  end

  class ReadonlyError < Error
    def initialize(name)
      @name = name
    end

    def to_s
      "#{@name} is not allowed when the client is set to readonly"
    end
  end


end
