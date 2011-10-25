require 'spec_helper'

describe ExactTarget do

  def self.test_et(method, *args, &block)
    desc = method.to_s
    desc << " with #{args.inspect}" unless args.empty?
    specify(desc) do
      @res = et_request(method, args.map { |a| a.is_a?(Proc) ? a.call : a }, desc)
      instance_eval(&block)
    end
  end

  #################################################################

  before(:all) do
    @logger = mock(:logger)
    @xml = YAML.load(File.read __FILE__.sub('_spec.rb', '_data.yml'))
    ExactTarget.configure do |config|
      config.base_url = 'https://base.url.com/foo'
      config.username = 'a_user'
      config.password = 'a_pass'
      config.logger   = @logger
    end
  end

  before(:each) do
    @atts = ['Email Address', 'Status', 'Email Type', 'First Name',
             'Last Name', 'Title', 'Region'].map do |a|
      stub :att, :name => a
    end
  end

  @example_subscriber = Proc.new do
    ExactTarget::Subscriber.new.tap do |sub|
      sub.email_address = 'someone@somehwere.com'
      sub.status        = 'active'
      sub.email_type    = 'HTML'
      sub.first_name    = 'Some'
      sub.last_name     = 'One'
      sub.title         = 'Director of HR'
      sub.region        = 'Midwest'
    end
  end

  specify "Subscriber constant" do
    ExactTarget.should_receive(:subscriber_class).and_return('SC')
    ExactTarget::Subscriber.should == 'SC'
    expect { ExactTarget::BogusConstant }.should raise_error
  end

  specify :subscriber_class do
    ExactTarget.should_receive(:accountinfo_retrieve_attrbs).once.and_return(@atts)
    clazz = ExactTarget.send(:subscriber_class)
    clazz.should == ExactTarget.send(:subscriber_class)
    s = clazz.new
    s.first_name = 'Da'
    s.Email__Address = 'foo@bar.com'
    s.region = 42
    s.First__Name.should == 'Da'
    s.email_address.should == 'foo@bar.com'
    s.to_s.should == 'foo@bar.com'
  end

  test_et :accountinfo_retrieve_attrbs do
    @res.size.should == 2

    @res = @res.last
    @res.is_a?(ExactTarget::ListProfileAttribute).should be_true
    @res.default_value.should == 'HTML'
    @res.min_size.should == 0
    @res.max_size.should == 2000
    @res.values.should == %w(HTML Text)
    @res.display.should == 'A2 name'
    @res.required.should be_true
    @res.name.should == 'A2'
    @res.subscriber_editable.should == 1
    @res.data_type.should == 'text'
    @res.description.should == 'A2 description'
    @res.to_s.should == 'A2'
  end

  test_et :list_retrieve, 'epub test' do
    @res.should == [42, 47]
  end

  test_et :list_retrieve, 42 do
    @res.should be_a(ExactTarget::ListInformation)
    @res.unsub_count.should == 1596
    @res.subscriber_count.should == 15287
    @res.bounce_count.should == 4145
    @res.modified.should be_a(Date)
    @res.held_count.should == 120
    @res.list_type.should == 'Private'
    @res.active_total.should == 9426
    @res.list_name.should == 'My Test List'
    @res.to_s.should == 'My Test List'
  end

  test_et :list_add, "Epub Test", :private do
    @res.should == 53
  end

  test_et :list_edit, 42, "Epub Test - RENAME" do
    @res.should == 42
  end

  test_et :list_import, [72, 33, 99], 'sometestfile.txt',
          %w(some_field other_field),
          :email_address => 'testme@nowhere.com' do
    @res.should == 841
  end

  test_et :list_importstatus, 119792 do
    @res.should == 'Complete'
  end

  specify "list_retrieve_sub with bogus status" do
    expect do
      ExactTarget.list_retrieve_sub(42, :bogus)
    end.should raise_error(/Invalid status:/)
  end

  test_et :list_retrieve_sub, 42, 'Active' do
    @res.size.should == 2

    @res = @res.last
    @res.status.should == "Active"
    @res.first_name.should == "Mary"
    @res.last_name.should == "Smith"
    @res.email_type.should == "HTML"
    @res.email_address.should == "mary@example.com"
    @res.to_s.should == "mary@example.com"
  end

  test_et :list_delete, 42 do
    @res.should == 42
  end

  test_et :list_retrievegroups do
    @res.size.should == 2

    @res = @res.last
    @res.should be_a(ExactTarget::ListGroupInformation)
    @res.group_id.should == 875
    @res.parentlist_id.should == 77
    @res.description.should == "test desc"
    @res.group_name.should == "test group"
    @res.to_s.should == "test group"
  end

  test_et :list_refresh_group, 3514 do
    @res.should == 6127
  end

  test_et :batch_inquire, 8912 do
    @res.should == 'Completed'
  end

  #################################################################

  test_et :subscriber_add, 1234, @example_subscriber, :status => 'active', :ChannelMemberID => 5678 do
    @res.should == 12334566
  end

  test_et :subscriber_edit, 63718, 'user@email.com', @example_subscriber,
                            :status => 'unsub',
                            :reason => 'insert your unsubscribe reason here',
                            :ChannelMemberID => 5678 do
    @res.should == 12334566
  end

  test_et :subscriber_retrieve, 123456, 'someone@example.com' do
    @res.size.should == 1

    @res = @res.last
    @res.should be_a(ExactTarget::SubscriberInformation)
    @res.subid.should == 125704849
    @res.listid.should == 63718
    @res.list_name.should == 'Newsletter List'

    @res = @res.subscriber
    @res.email_address.should == "jdoe@example.com"
    @res.first_name.should == "John"
    @res.region.should == ""
    @res.email_type.should == "HTML"
    @res.title.should == ""
    @res.status.should == "Active"
    @res.last_name.should == "Doe"
  end

  test_et :subscriber_retrieve, 123456789 do
    @res.size.should == 2

    @res = @res.last
    @res.should be_a(ExactTarget::SubscriberInformation)
    @res.subid.should == 125504849
    @res.listid.should == 63719
    @res.list_name.should == 'TechnologyUpdate'

    @res = @res.subscriber
    @res.email_address.should == "jdoe@example.com"
    @res.first_name.should == "John"
    @res.region.should == ""
    @res.email_type.should == "HTML"
    @res.title.should == ""
    @res.status.should == "Active"
    @res.last_name.should == "Doe"
  end

  test_et :subscriber_delete, 112233445566, 'bob@hotmail.com' do
    @res.should be_true
  end

  test_et :subscriber_delete, 112233445566 do
    @res.should be_true
  end

  test_et :subscriber_masterunsub,
          %w(Email1@example.com Email2@example.com Email3@example.com) do
    @res.size.should == 3
    (1..3).each do |i|
      @res["Email#{i}@example.com"].should == "masterunsub"
    end
  end

  #################################################################

  test_et :email_retrieve do
    verify_email_retrieve
  end

  test_et :email_retrieve, 'Welcome to Fortune One!' do
    verify_email_retrieve
  end

  test_et :email_retrieve, :start_date => Date.parse('2008-09-15'),
                           :end_date => Date.parse('2008-10-15') do
    verify_email_retrieve
  end

  test_et :email_retrieve, 'Welcome to Fortune One!',
                           :start_date => Date.parse('2008-09-15'),
                           :end_date => Date.parse('2008-10-15') do
    verify_email_retrieve
  end

  def verify_email_retrieve
    @res.size.should == 3

    @res = @res.last
    @res.emailid.should == 205449
    @res.emailname.should == 'ET 04 Demo Email'
    @res.emailsubject.should == 'ET 04 Demo Email'
    @res.emailcreateddate.should == Date.parse('2004-03-19')
    @res.categoryid.should == 75163
    @res.to_s.should == 'ET 04 Demo Email'
  end

  test_et :email_add, 'Your body email name',
                      'Your email subject line',
                      :body => 'Your HTML email body' do
    @res.should == 44180
  end

  test_et :email_add, 'Your file email name',
                      'Your email subject line',
                      :file => 'Filename' do
    @res.should == 44180
  end

  test_et :email_add_text, 155324, :body => 'Your text email body' do
    @res.should be_true
  end

  test_et :email_add_text, 155325, :file => 'Filename' do
    @res.should be_true
  end

  test_et :email_retrieve_body, 12344556 do
    @res.should == '<h1>...BODY...</h1>'
  end

  #################################################################

  test_et :triggeredsend_add, 'recipient@foo.com', 'email_name', {:attr_1 => 'val_1', :attr_2 => 'val_2'} do
    @res.should == 0
  end

  #################################################################

  test_et :job_send, 112233, [12345, 12346],
          :suppress_ids => 35612,
          :from_name => 'FrName',
          :from_email => 'fr.email@nowhere.com',
          :additional => 'addit',
          :multipart_mime => true,
          :track_links => false,
          :send_date => '5/3/2011',
          :send_time => '17:35',
          :test_send => true do
    @res.should == 2030602
  end

  specify "job_send with error" do
    expect do
      et_request :job_send, [:BOGUS, nil, nil], "job send with error"
    end.should raise_error(
      ExactTarget::Error,
      'ExactTarget error #68: File does not exist.'
    )
  end

  #################################################################

  context :send_to_exact_target do
    before(:each) do
      @path = '/foo?qf=xml&xml=%3Csomexml/%3E'
      @http = mock('Net::HTTP')
      @http.should_receive(:use_ssl=).with(true)
      @http.should_receive(:open_timeout=).with(2)
      @http.should_receive(:read_timeout=).with(5)
      Net::HTTP.should_receive(:new).with('base.url.com', 443).and_return(@http)
    end

    specify :success do
      resp = stub('Net::HTTPSuccess', :is_a? => true, :body => 'xyz')
      @http.should_receive(:get).with(@path).and_return(resp)
      ExactTarget.send_to_exact_target('<somexml/>').should == 'xyz'
    end

    specify :error do
      resp = stub('Net::HTTPFailure', :error! => 'err')
      @http.should_receive(:get).with(@path).and_return(resp)
      ExactTarget.send_to_exact_target('<somexml/>').should == 'err'
    end
  end

  specify "method_missing should throw normal error when bogus method" do
    expect { ExactTarget.bogus }.should raise_error
  end

  context :net_http_or_proxy do
    after { ExactTarget.configuration.http_proxy = nil }

    specify :proxy do
      ExactTarget.configuration.http_proxy = 'http://a.proxy.com:9001'
      clazz = ExactTarget.send(:net_http_or_proxy)
      # A proxy class should have the same methods
      clazz.should_not == Net::HTTP
      (Net::HTTP.methods - clazz.methods).should be_empty
      (Net::HTTP.instance_methods - clazz.instance_methods).should be_empty
    end

    specify :standard do
      ExactTarget.send(:net_http_or_proxy).should == Net::HTTP
    end
  end

  #################################################################

  private

  def et_request(method, args, desc)
    request, response = et_xml(method, args, desc)
    request = <<-END.gsub(/>\s+</m, '><').strip
      <?xml version="1.0"?>
      <exacttarget>
        <authorization>
          <username>a_user</username>
          <password>a_pass</password>
        </authorization>
        <system>
          #{request}
        </system>
      </exacttarget>
    END
    response = <<-END.gsub(/>\s+</m, '><').strip
      <?xml version='1.0'?>
      <exacttarget>
        <system>
          #{response}
        </system>
      </exacttarget>
    END
    @logger.should_receive(:debug).twice
    ExactTarget.should_receive(:send_to_exact_target).with(request).and_return(response)
    unless method == :accountinfo_retrieve_attrbs
      ExactTarget.stub :accountinfo_retrieve_attrbs => @atts
    end
    ExactTarget.send(method, *args)
  end

  def et_xml(method, args, desc)
    xml = @xml[method.to_s] || {}
    args = args.map { |a| a.is_a?(Hash) ? 'HASH' : a }
    if args.size == 1 and xml.has_key?(k = args.first)
      xml = xml[k]
    elsif xml.has_key?(k = args.join(', '))
      xml = xml[k]
    elsif xml.has_key?(k = args.hash)
      xml = xml[k]
    end
    %w(request response).map do |k|
      xml[k] or raise "Can not determine #{k} xml for #{desc}"
    end
  end

end
