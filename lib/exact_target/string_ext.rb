# Add support for String#underscore if ActiveSupport not available
# as well as Object#blank?

unless String.instance_methods.map(&:to_sym).include?(:underscore)
  class String
    def underscore
      gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end
  end
end

unless Object.instance_methods.map(&:to_sym).include?(:blank?)
  class Object
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end
end
