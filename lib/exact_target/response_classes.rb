require 'erb'

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
            self, :Subscriber, accountinfo_retrieve_attrbs.map(&:name), :Status
          )
        end

        def base.const_missing(name)
          if name.to_sym == :Subscriber
            subscriber_class
          else
            super
          end
        end
      end

      def class_from_et_attributes(base, name, *attribute_names)
        attributes = attribute_names.flatten.uniq.map do |a|
          [a.to_s.underscore.gsub(' ', '_'), a.to_s.gsub(' ', '__')]
        end
        class_def = class_template.result(binding)
        base.module_eval(class_def)
        base.const_get(name)
      end

      def class_template
        @class_template ||= ERB.new File.read(File.expand_path '../response_class.erb', __FILE__)
      end

    end
  end
end
