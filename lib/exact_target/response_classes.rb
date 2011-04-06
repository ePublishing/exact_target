module ExactTarget
  #
  # Response classes for ExactTarget.  We'll use these rather
  # than just stuff it all in a hash as it allows us to more
  # easily map between ugly ET names (e.g. GroupID) to ruby-friendly
  # names (e.g. group_id).
  #
  module ResponseClasses
    class << self

      def extended(base)
        class_from_et_attributes base, :ListProfileAttribute,
          :name, :description, :default_value, :data_type, :required,
          :min_size, :max_size, :subscriber_editable, :display, :values

        class_from_et_attributes base, :ListInformation,
         :list_name, :list_type, :modified, :subscriber_count,
         :active_total, :held_count, :bounce_count, :unsub_count

        class_from_et_attributes base, :ListGroupInformation,
          :groupName, :groupID, :parentlistID, :description

        class_from_et_attributes base, :SubscriberInformation,
          :subid, :listid, :list_name, :subscriber

        class_from_et_attributes base, :EmailInformation,
          :emailname, :emailid, :emailsubject, :emailcreateddate, :categoryid

        def base.subscriber_class
          @subscriber_class ||= ResponseClasses.class_from_et_attributes(
            self, :Subscriber, accountinfo_retrieve_attrbs.map(&:name)
          )
        end
      end

      def class_from_et_attributes(base, name, *attribute_names)
        lines = ["class #{name}"]
        attribute_names.flatten.each_with_index do |a, i|
          add_et_attribute(lines, a.to_s, i)
        end
        lines << "end"
        base.module_eval(lines * "\n")
        base.const_get(name)
      end

      def add_et_attribute(lines, attr, i)
        rb_a = attr.underscore.gsub(' ', '_')
        et_a = attr.gsub(' ', '__')
        lines << "attr_accessor :#{et_a}"
        if rb_a != et_a
          lines << "alias :#{rb_a} :#{et_a}"
          lines << "alias :#{rb_a}= :#{et_a}="
        end
        if i == 0
          lines << "alias :to_s :#{et_a}"
        end
      end

    end
  end
end
