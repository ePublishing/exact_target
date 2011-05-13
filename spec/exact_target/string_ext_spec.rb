require 'spec_helper'

describe 'ExactTarget::StringExt' do

  specify :underscore do
    "Foo::BarExt-Stuff".underscore.should == 'foo/bar_ext_stuff'
  end

  specify :blank? do
    "foo".blank?.should be_false
    "".blank?.should be_true
    nil.blank?.should be_true
  end

end
