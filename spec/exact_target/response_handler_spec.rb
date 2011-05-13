require 'spec_helper'

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

  context :cast_value do
    ['3',         3,
     '-5',        -5,
     '+3.79e-4',  0.000379,
     'true',      true,
     'false',     false,
     '3/15/2002', Date.parse('2002-03-15'),
     "\t a b \n", "a b",
    ].each_slice(2) do |v, res|
      it "should handle #{v}" do
        @handler.send(:cast_value, v).should == res
      end
    end
  end

end
