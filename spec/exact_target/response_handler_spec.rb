describe ExactTarget::ResponseHandler do

  before(:all) do
    @handler = ExactTarget::ResponseHandler.new(stub :config)
  end

  it "should throw error when failure handling id result" do
    info = stub(:info, :text => 'BOGUS')
    resp = stub(:response, :xpath => [info], :to_s => 'BOGUS<s>')
    expect {
      @handler.send(:handle_id_result, resp, :info_tag, :id_tag, /success/i)
    }.should raise_error(ExactTarget::Error, 'ExactTarget error #0: Unsupported id result: BOGUS<s>')
  end

end
