require 'builder'

module ExactTarget
  class RequestBuilder

    def initialize(config)
      @config = config
    end

    def accountinfo_retrieve_attrbs
      ensure_executable!("accountinfo_retrieve_attrbs")
      build(:accountinfo, :retrieve_attrbs)
    end

    def list_add(list_name, list_type=nil)
      ensure_executable!("list_add")
      list_type = :public unless %w(public private salesforce).include?(list_type.to_s)
      build(:list, :add) do |li|
        li.list_type list_type.to_s
        li.list_name list_name.to_s
      end
    end

    def list_edit(list_id, new_list_name)
      ensure_executable!("list_edit")
      build(:list, :edit, :listid, list_id) do |li|
        li.list_name new_list_name.to_s
      end
    end

    def list_retrieve(id_or_name=nil)
      ensure_executable!("list_retrieve")
      if id_or_name.is_a?(Fixnum) or id_or_name =~ /^\d+$/
        build(:list, :retrieve, :listid, id_or_name.to_i)
      else
        build(:list, :retrieve, :listname, id_or_name)
      end
    end

    def list_import(list_id, file_name, file_mapping, options={})
      ensure_executable!("list_import")
      options = list_import_default_options(options, file_name)
      build(:list, :import, :listid, list_id) do |li|
        li.tags_from_options! options, :file_name, :email_address, :file_type, :column_headings
        li.file_mapping do |fm|
          file_mapping.each { |m| fm.field(m) }
        end
        li.tags_from_options! options, :import_type, :returnid, :encrypted, :encrypt_format
      end
    end

    def list_importstatus(import_id)
      ensure_executable!("list_importstatus")
      build(
        :list, :import,
        :sub_action => :importstatus,
        :search_type => :omit,
        :search_value => import_id
      )
    end

    def list_retrieve_sub(list_id, status=nil)
      ensure_executable!("list_retrieve_sub")
      unless status.nil? or %w(Active Unsubscribed Returned Undeliverable Deleted).include?(status)
        raise "Invalid status: #{status}"
      end
      build(:list, :retrieve_sub, :listid, list_id) do |li|
        li.search_status status unless status.nil?
      end
    end

    def list_delete(id)
      ensure_executable!("list_delete")
      build(:list, :delete, :listid, id)
    end

    def list_retrievegroups
      ensure_executable!("list_retrievegroups")
      build(:list, :retrievegroups, :groups)
    end

    def list_refresh_group(group_id)
      ensure_executable!("list_refresh_group")
      build(
        :list, :refresh_group,
        :sub_action => nil,
        :search_type => :omit,
        :search_value => group_id,
        :search_value2 => nil
      )
    end

    def batch_inquire(batch_id)
      ensure_executable!("batch_inquire")
      build(
        :batch, :inquire, :batchid, batch_id,
        :sub_action => nil,
        :search_value2 => nil
      )
    end

    ###################################################################

    def subscriber_add(list_id, subscriber, options={})
      ensure_executable!("subscriber_add")
      subscriber_edit(list_id, nil, subscriber, options)
    end

    def subscriber_edit(list_id, orig_email, subscriber, options={})
      ensure_executable!("subscriber_edit")
      options = subscriber_edit_default_options(options)
      subscriber = subscriber.to_et_hash if subscriber.is_a?(Subscriber)
      action = orig_email.nil? ? :add : :edit
      build(:subscriber, action, :listid, list_id, :search_value2 => orig_email) do |sub|
        sub.values do |vs|
          subscriber.each do |k, v|
            vs.tag!(k.to_s, v) unless k.to_s =~ /status/i
          end
          vs.status options[:status].to_s
          vs.reason options[:reason] if options.has_key? :reason
          vs.ChannelMemberID options[:ChannelMemberID] if options.has_key? :ChannelMemberID
        end
        sub.update options[:update] if orig_email.nil?
      end
    end

    def subscriber_retrieve(id, email=nil)
      ensure_executable!("subscriber_retrieve")
      type = email.blank? ? :subid : :listid
      build(:subscriber, :retrieve, type, id, :search_value2 => email)
    end

    def subscriber_delete(id, email=nil)
      ensure_executable!("subscriber_delete")
      type = email.blank? ? :subid : :listid
      build(:subscriber, :delete, type, id, :search_value2 => email)
    end

    def subscriber_masterunsub(*email_addresses)
      ensure_executable!("subscriber_masterunsub")
      build(:subscriber, :masterunsub, :emailaddress, :search_value => :omit) do |sub|
        sub.search_value do |sv|
          email_addresses.flatten.each { |a| sv.emailaddress(a) }
        end
      end
    end

    ###################################################################

    def email_retrieve(name=nil, options={})
      ensure_executable!("email_retrieve")
      name, options = nil, name if name.is_a?(Hash)
      start_date, end_date = %w(start_date end_date).map do |n|
        et_date options[n.to_sym]
      end
      type = unless start_date.nil? and end_date.nil?
               name.nil? ? :daterange : :emailnameanddaterange
             else
               name.nil? ? nil : :emailname
             end
      build(:email, :retrieve, type, name, :sub_action => :all, :search_value2 => nil) do |em|
        em.daterange do |r|
          r.startdate start_date if start_date
          r.enddate   end_date   if end_date
        end
      end
    end

    def email_add(name, subject, options)
      ensure_executable!("email_add")
      build(:email, :add, :search_type => :omit, :search_value => :omit, :sub_action => 'HTMLPaste') do |em|
        em.category
        em.email_name name
        em.email_subject subject
        if options.has_key? :body
          em.email_body { |eb| eb.cdata! options[:body] }
        elsif options.has_key? :file
          em.file_name options[:file]
        end
      end
    end

    def email_add_text(email_id, options)
      ensure_executable!("email_add_text")
      build(:email, :add, :search_type => :emailid,
                  :search_value => email_id, :sub_action => :text) do |em|
        if options.has_key? :body
          em.email_body { |eb| eb.cdata! options[:body] }
        elsif options.has_key? :file
          em.file_name options[:file]
        end
      end
    end

    def email_retrieve_body(email_id)
      ensure_executable!("email_retrieve_body")
      build(:email, :retrieve, :emailid, email_id, :sub_action => :htmlemail) do |em|
        em.search_value2
        em.search_value3
      end
    end

    ###################################################################

    def triggeredsend_add(email, customer_key, attributes = {})
      ensure_executable!("triggeredsend_add", email)
      build(:triggeredsend, :add) do |xml|
        xml.TriggeredSend :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchemainstance",
                          :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
                          :"xmlns"     => "http://exacttarget.com/wsdl/partnerAPI" do
          xml.TriggeredSendDefinition do
            xml.CustomerKey customer_key
          end
          xml.Subscribers do
            xml.EmailAddress email
            xml.SubscriberKey email
          end
          attributes.each do |key, value|
            xml.Attributes do
              xml.Name key.to_s
              xml.Value {|v| v.cdata! value.to_s }
            end
          end
        end
      end
    end

    ###################################################################

    def job_send(email_id, list_ids, options={})
      ensure_executable!("job_send")
      options = job_send_default_options(options)

      build(:job, :send, :emailid, email_id) do |job|
        job.tags_from_options! options, :from_name, :from_email, :additional,
                                        :multipart_mime, :track_links,
                                        :send_date, :send_time
        job_send_id_list job, :lists, list_ids
        job_send_id_list job, :suppress, options[:suppress_ids]
        job.test_send options[:test_send]
      end
    end

    ###################################################################

    def list_bulkasync(list_id, list_status = nil)
      build(
        :list, :bulkasync,
        :sub_action => 'Subs_ToFTP',
        :search_type => :listid,
        :search_value => list_id
      ) do |xml|
        xml.search_status list_status if list_status
      end
    end

    def subscriber_bulkasync(list_id)
      build(:subscriber, :BulkAsync,
        :sub_action => "SubsStatus_ToFTP",
        :search_type => "lid",
        :search_value => list_id)
    end

    # "retrieves complete tracking data for an email send"
    def tracking_bulkasync_all(job_id, start_date = nil, end_date = nil)
      build(:tracking, :BulkAsync,
        :sub_action => "all_ToFTP",
        :search_type => "jobID",
        :search_value => job_id) do |xml|
        if start_date || end_date
          start_date = start_date.strftime("%m/%d/%Y") if start_date.respond_to?(:strftime)
          end_date = end_date.strftime("%m/%d/%Y") if end_date.respond_to?(:strftime)
          xml.daterange do
            xml.startdate start_date
            xml.enddate end_date
          end
        end
      end
    end

    def tracking_bulkasync_all_attributes(job_id, start_date = nil, end_date = nil)
      build(:tracking, :BulkAsync,
        :sub_action => "all_attributes_ToFTP",
        :search_type => "jobID",
        :search_value => job_id) do |xml|
        if start_date || end_date
          start_date = start_date.strftime("%m/%d/%Y") if start_date.respond_to?(:strftime)
          end_date = end_date.strftime("%m/%d/%Y") if end_date.respond_to?(:strftime)
          xml.daterange do
            xml.startdate start_date
            xml.enddate end_date
          end
        end
      end
    end

    def tracking_sent_bulkasync_all(job_id)
      build(:tracking, :Sent_BulkAsync,
        :sub_action => "all_ToFTP",
        :search_type => "jobID",
        :search_value => job_id)
    end

    def tracking_sent_bulkasync_all_attributes(job_id, start_date = nil, end_date = nil)
        build(:tracking, :Sent_BulkAsync,
          :sub_action => "all_attributes_ToFTP",
          :search_type => "jobID",
          :search_value => job_id) do |xml|
          if start_date || end_date
            start_date = start_date.strftime("%m/%d/%Y") if start_date.respond_to?(:strftime)
            end_date = end_date.strftime("%m/%d/%Y") if end_date.respond_to?(:strftime)
            xml.daterange do
              xml.startdate start_date
              xml.enddate end_date
            end
          end
        end
      end

    ###################################################################
    private
    ###################################################################

    def list_import_default_options(options, file_name)
      options = options.dup
      options[:file_name]         = file_name
      options[:file_type]       ||= (file_name =~ /\.txt$/i ? 'tab' : 'csv')
      options[:column_headings] ||= true
      options[:import_type]     ||= 0
      options[:returnid]        ||= true
      options[:encrypted]       ||= false
      options
    end

    def subscriber_edit_default_options(options)
      options = options.dup
      options[:status] = :active unless options[:status].to_s == 'unsub'
      options[:update] = true unless options[:update] == false
      options
    end

    def job_send_default_options(options)
      options = options.nil? ? {} : options.dup # Don't munge hash passed in
      options[:multipart_mime] = false unless options.has_key? :multipart_mime
      options[:track_links]    = true  unless options.has_key? :track_links
      options[:test_send]      = false unless options.has_key? :test_send
      options[:send_date]    ||= :immediate
      options[:suppress_ids] ||= []
      options
    end

    def job_send_id_list(job, tag, ids)
      job.tag!(tag.to_s) do |li|
        [ids].flatten.compact.each { |id| li.list id }
      end
    end

    def et_date(d)
      d = Date.parse(d) if d.is_a?(String)
      [d.month, d.day, d.year] * '/' if d
    end

    def build(system_name, action, search_type=nil, search_value=nil, options=nil, &block)
      options = parse_options(search_type, search_value, options)
      xml = Builder::XmlMarkup.new
      xml = xml.exacttarget do |et|
        et.authorization do |a|
          a.username @config.username
          a.password @config.password
        end
        et.system do |s|
          build_system(s, system_name, action, options, &block)
        end
      end
      %Q[<?xml version="1.0"?>#{xml}]
    end

    def parse_options(search_type, search_value, options)
      options, search_type = search_type, nil if search_type.is_a?(Hash)
      options, search_value = search_value, nil if search_value.is_a?(Hash)
      options ||= {}
      { :search_type => search_type, :search_value => search_value }.merge(options)
    end

    def build_system(s, system_name, action, options, &block)
      s.system_name system_name.to_s
      s.action action.to_s
      [:sub_action, :search_type, :search_value, :search_value2].each do |name|
        build_system_option(s, name, options[name]) if options.has_key? name
      end
      yield(s) if block_given?
    end

    def build_system_option(s, name, value)
      if name == :search_value and value.is_a?(Array)
        s.search_values do |ss|
          value.each { |v| ss.search_value v }
        end
      elsif value != :omit
        s.tag! name.to_s, value.to_s
      end
    end

    def ensure_executable!(method, email = nil)
      # stop if the method is readonly
      raise ReadonlyError.new(method) if @config.readonly && @config.readonly.include?(method.to_sym)

      ensure_sendable!(email) if email
    end

    def ensure_sendable!(email)
      if @config.email_whitelist && !@config.email_whitelist.match(email)
        raise WhitelistError.new(email)
      end

      if @config.email_blacklist && @config.email_blacklist.match(email)
        raise BlacklistError.new(email)
      end
    end

  end
end
