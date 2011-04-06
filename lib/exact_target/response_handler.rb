require 'builder'

module ExactTarget
  #
  # This class is responsible for turning parsed ExactTarget response xml
  # into data that applications can use
  #
  class ResponseHandler

    def initialize(config)
      @config = config
    end

    def handle_import_id_result(resp)
      handle_id_result resp, :import_info, :importid, /is being imported/i
    end

    %w(email job list subscriber).each do |t|
      define_method "handle_#{t}_id_result", lambda { |resp|
        handle_id_result resp, "#{t}_info", "#{t}_description", /success/i
      }
    end

    def accountinfo_retrieve_attrbs(resp)
      resp.xpath('//attribute').map do |a|
        create_result(ListProfileAttribute, a) do |child|
          child.children.map { |v| cast_value(v.text) } if child.name == 'values'
        end
      end
    end

    alias :list_add :handle_list_id_result

    alias :list_edit :handle_list_id_result

    def list_retrieve(resp)
      if resp.xpath('//list/list_name').size == 1
        resp.xpath('//list[1]').map do |list|
          create_result(ListInformation, list)
        end.first
      else
        resp.xpath('//listid').map do |id|
          id.text.to_i
        end
      end
    end

    alias :list_import :handle_import_id_result

    def list_importstatus(resp)
      resp.xpath('//import_info[1]').first.text
    end

    def list_retrieve_sub(resp)
      resp.xpath('//subscriber').map do |s|
        return [] if s.text =~ /no subscribers found/i
        create_result(Subscriber, s)
      end
    end

    alias :list_delete :handle_list_id_result

    def list_retrievegroups(resp)
      resp.xpath('//group').map do |group|
        create_result(ListGroupInformation, group)
      end
    end

    def list_refresh_group(resp)
      resp.xpath('//groupRefresh/groupAsyncID[1]').first.text.to_i
    end

    def batch_inquire(resp)
      resp.xpath('//Batch/status[1]').first.text
    end

    ###################################################################

    alias :subscriber_add :handle_subscriber_id_result

    alias :subscriber_edit :handle_subscriber_id_result

    def subscriber_retrieve(resp)
      resp.xpath('//subscriber').map do |s|
        return [] if s.text =~ /no subscribers found/i
        sri = create_result(SubscriberInformation, s)
        sri.subscriber = create_result(Subscriber, s)
        sri
      end
    end

    alias :subscriber_delete :handle_subscriber_id_result

    def subscriber_masterunsub(resp)
      resp = resp.xpath('//subscriberunsub').map do |su|
        %w(emailaddress status).map { |p| su.xpath(".//#{p}[1]").first.text }
      end
      Hash[resp]
    end

    ###################################################################

    def email_retrieve(resp)
      resp.xpath('//emaillist').map do |el|
        create_result(EmailInformation, el)
      end
    end

    def email_add(resp)
      resp.xpath('//emailID[1]').first.text.to_i
    end

    alias :email_add_text :handle_email_id_result

    def email_retrieve_body(resp)
      resp.xpath('//htmlbody[1]').first.text
    end

    ###################################################################

    alias :job_send :handle_job_id_result

    ###################################################################
    private
    ###################################################################

    def handle_id_result(resp, info_tag, id_tag, success_regex)
      info = resp.xpath("//#{info_tag}[1]").first
      if !info.nil? and info.text =~ success_regex
        id = resp.xpath("//#{id_tag}[1]").first
        id.nil? ? true : cast_value(id.text)
      else
        raise Error.new(0, "Unsupported id result: #{resp.to_s}")
      end
    end

    def create_result(clazz, node, &block)
      ret = clazz.new
      node.children.each do |child|
        if ret.respond_to? "#{child.name}="
          val = yield(child) if block_given?
          val = cast_value(child.text) if val.nil?
          ret.send "#{child.name}=", val
        end
      end
      ret
    end

    def cast_value(v)
      case v
      when /^[+-]?\d+$/
        v.to_i
      when /^([+-]?)(?=\dâ\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/
        v.to_f
      when /^true$/i
        true
      when /^false$/i
        false
      when %r{^\d+/\d+/\d+ \d+:\d+:\d+ [AP]M$}i, %r{^\d+/\d+/\d+$}i
        DateTime.parse(v)
      else
        v.strip
      end
    end

  end
end
