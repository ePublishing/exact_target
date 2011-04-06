require 'builder'

module ExactTarget
  class RequestBuilder

    def initialize(config)
      @config = config
    end

    def accountinfo_retrieve_attrbs
      build(:accountinfo, :retrieve_attrbs)
    end

    def list_add(list_name, list_type=nil)
      list_type = :public unless %w(public private salesforce).include?(list_type.to_s)
      build(:list, :add) do
        list_type list_type.to_s
        list_name list_name.to_s
      end
    end

    def list_edit(list_id, new_list_name)
      build(:list, :edit, :listid, list_id) do
        list_name new_list_name.to_s
      end
    end

    def list_retrieve(id_or_name=nil)
      if id_or_name.is_a?(Fixnum) or id_or_name =~ /^\d+$/
        build(:list, :retrieve, :listid, id_or_name.to_i)
      else
        build(:list, :retrieve, :listname, id_or_name)
      end
    end

    def list_import(list_id, file_name, file_mapping, options={})
      build(:list, :import, :listid, list_id) do
        file_name       file_name
        email_address   options[:email_address].to_s
        file_type       options[:file_type] || (file_name =~ /\.txt$/i ? 'tab' : 'csv')
        column_headings options[:column_headings] || true
        file_mapping do |fm|
          file_mapping.each { |m| fm.field(m) }
        end
        import_type     options[:import_type] || 0
        returnid        options[:returnid] || true
        encrypted       options[:encrypted] || false
        encrypt_format  options[:encrypt_format]
      end
    end

    def list_importstatus(import_id)
      build(
        :list, :import,
        :sub_action => :importstatus,
        :search_type => :omit,
        :search_value => import_id
      )
    end

    def list_retrieve_sub(list_id, status=nil)
      unless status.nil? or %w(Active Unsubscribed Returned Undeliverable Deleted).include?(status)
        raise "Invalid status: #{status}"
      end
      build(:list, :retrieve_sub, :listid, list_id) do
        search_status status unless status.nil?
      end
    end

    def list_delete(id)
      build(:list, :delete, :listid, id)
    end

    def list_retrievegroups
      build(:list, :retrievegroups, :groups)
    end

    def list_refresh_group(group_id)
      build(
        :list, :refresh_group,
        :sub_action => nil,
        :search_type => :omit,
        :search_value => group_id,
        :search_value2 => nil
      )
    end

    def batch_inquire(batch_id)
      build(
        :batch, :inquire, :batchid, batch_id,
        :sub_action => nil,
        :search_value2 => nil
      )
    end

    ###################################################################

    def subscriber_add(list_id, subscriber_info, update=true)
      build(:subscriber, :add, :listid, list_id, :search_value2 => nil) do
        values do |vs|
          subscriber_info.each { |k, v| vs.tag! k.to_s, v }
        end
        tag! 'update', update
      end
    end

    def subscriber_edit(list_id, orig_email, subscriber_info)
      build(:subscriber, :edit, :listid, list_id, :search_value2 => orig_email) do
        values do |vs|
          subscriber_info.each { |k, v| vs.tag! k.to_s, v }
        end
      end
    end

    def subscriber_retrieve(id, email=nil)
      type = email.blank? ? :subid : :listid
      build(:subscriber, :retrieve, type, id, :search_value2 => email)
    end

    def subscriber_delete(id, email=nil)
      type = email.blank? ? :subid : :listid
      build(:subscriber, :delete, type, id, :search_value2 => email)
    end

    def subscriber_masterunsub(*email_addresses)
      build(:subscriber, :masterunsub, :emailaddress, :search_value => :omit) do
        search_value do |sv|
          email_addresses.flatten.each { |a| sv.emailaddress(a) }
        end
      end
    end

    ###################################################################

    def email_retrieve(name=nil, options={})
      name, options = nil, name if name.is_a?(Hash)
      start_date, end_date = %w(start_date end_date).map do |n|
        et_date options[n.to_sym]
      end
      type = unless start_date.nil? and end_date.nil?
               name.nil? ? :daterange : :emailnameanddaterange
             else
               name.nil? ? nil : :emailname
             end
      build(:email, :retrieve, type, name, :sub_action => :all, :search_value2 => nil) do
        daterange do |r|
          r.startdate start_date if start_date
          r.enddate   end_date    if end_date
        end
      end
    end

    def email_add(name, subject, options)
      build(:email, :add, :search_type => :omit, :search_value => :omit, :sub_action => 'HTMLPaste') do
        category
        email_name name
        email_subject subject
        if options.has_key? :body
          email_body { |eb| eb.cdata! options[:body] }
        elsif options.has_key? :file
          file_name options[:file]
        end
      end
    end

    def email_add_text(email_id, options)
      build(:email, :add, :search_type => :emailid,
                  :search_value => email_id, :sub_action => :text) do
        if options.has_key? :body
          email_body { |eb| eb.cdata! options[:body] }
        elsif options.has_key? :file
          file_name options[:file]
        end
      end
    end

    def email_retrieve_body(email_id)
      build(:email, :retrieve, :emailid, email_id, :sub_action => :htmlemail) do |e|
        e.search_value2
        e.search_value3
      end
    end

    ###################################################################

    def job_send(email_id, list_ids, options={})
      options = options.nil? ? {} : options.dup # Don't munge hash passed in
      options[:multipart_mime] = false unless options.has_key? :multipart_mime
      options[:track_links]    = true  unless options.has_key? :track_links
      options[:test_send]      = false unless options.has_key? :test_send
      options[:send_date]    ||= :immediate
      options[:suppress_ids] ||= []

      build(:job, :send, :emailid, email_id) do |job|
        %w(from_name from_email additional multipart_mime
           track_links send_date send_time).each do |field|
          job.tag! field, options[field.to_sym].to_s
        end
        job.lists do |li|
          [list_ids].flatten.compact.each { |id| li.list id }
        end
        job.suppress do |li|
          [options[:suppress_ids]].flatten.compact.each { |id| li.list id }
        end
        job.test_send options[:test_send]
      end
    end

    ###################################################################
    private
    ###################################################################

    def et_date(d)
      d = Date.parse(d) if d.is_a?(String)
      [d.month, d.day, d.year] * '/' if d
    end

    def build(system_name, action, search_type=nil, search_value=nil, options=nil, &block)
      options = parse_options(search_type, search_value, options)
      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version => "1.0", :encoding => nil
      xml = xml.exacttarget do |et|
        et.authorization do |a|
          a.username @config.username
          a.password @config.password
        end
        et.system do |s|
          s.system_name system_name.to_s
          s.action action.to_s
          [:sub_action, :search_type, :search_value, :search_value2].each do |k|
            if options[k] == :omit
              #ignore
            elsif k == :search_value and options[k].is_a?(Array)
              s.search_values do |ss|
                options[k].each { |v| ss.search_value v }
              end
            elsif options.has_key?(k)
              s.tag!(k.to_s, options[k].to_s)
            end
          end
          s.instance_eval(&block) if block_given?
        end
      end
      xml.to_s
    end

    def parse_options(search_type, search_value, options)
      options, search_type = search_type, nil if search_type.is_a?(Hash)
      options, search_value = search_value, nil if search_value.is_a?(Hash)
      options ||= {}
      { :search_type => search_type, :search_value => search_value }.merge(options)
    end

  end
end
