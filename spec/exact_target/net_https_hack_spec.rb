describe 'ExactTarget::NetHttpsHack' do

  it "should ignore those annoying cert warnings" do
    http = Net::HTTP.new(anything)
    http.instance_variable_get(:@ssl_context).verify_mode.should == OpenSSL::SSL::VERIFY_NONE
  end

end
