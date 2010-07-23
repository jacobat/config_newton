require 'spec_helper'

class SampleClass
  include ConfigNewton
end

describe ConfigNewton do
  describe '.configure' do
    before do
      SampleClass.send(:configurable) do
        property :foo, :default => 123
        property :bar
        property :baz, :default => 890
      end
    end
    
    it 'should define the configure method on the class' do
      SampleClass.should be_respond_to(:configure)
    end
    
    context 'setting values' do
      before do
        SampleClass.config[:foo] = nil
        SampleClass.config[:bar] = nil
      end
      
      it 'should accept a hash' do
        SampleClass.configure(:foo => 330, :bar => 555)
      end
      
      it 'should accept a block with an argument' do
        SampleClass.configure do |config|
          config.foo = 330
          config.bar = 555
        end
      end
      
      after do
        SampleClass.config.to_hash.should == {
          :foo => 330,
          :bar => 555,
          :baz => 890
        }
      end
    end
    
    it 'should accept a block with an argument' do
      
    end
  end
  
  describe '.configurable' do
    it 'should allow for configurables to be created' do
      SampleClass.send(:configurable, :abc)
      SampleClass.config.should be_respond_to(:abc)
    end
  
    it 'should allow for block configurable creation' do
      SampleClass.send(:configurable) do
        property :abc, :default => 123
        property :def
      end
    
      SampleClass.config.should be_respond_to(:def)
      SampleClass.config.abc.should == 123
    end
    
    it 'should be protected' do
      lambda{SampleClass.configurable(:abc)}.should raise_error(NoMethodError)
    end
  end
end
