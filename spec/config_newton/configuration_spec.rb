require 'spec_helper'

describe ConfigNewton::Configuration do
  subject { ConfigNewton::Configuration.new }
  
  describe '#add' do
    it 'should be able to add properties' do
      subject.add(:abc)
      subject.abc.should be_nil
    end
    
    it 'should be able to have a default' do
      subject.add(:abc, :default => 123)
      subject.abc.should == 123
    end
    
    it 'should raise an ArgumentError if no name is passed' do
      lambda{subject.add}.should raise_error(ArgumentError)
    end
  end
  
  describe '#to_hash' do
    it 'should be able to convert to a hash' do
      subject.add(:foo, :default => 123)
      subject.add(:bar)
      subject.add(:baz, :default => 890)
      subject.bar = 456
      subject.baz = 789
      subject.to_hash.should == {
        :foo => 123,
        :bar => 456,
        :baz => 789
      }
    end
  end
  
  it 'should be able to read and write to properties' do
    subject.add(:abc)
    subject.abc = 123
    subject.abc.should == 123
  end
  
  
  describe '#[]' do
    before do
      subject.add(:abc)
      subject.abc = 123
    end
    
    it 'should retrieve set values' do
      subject[:abc].should == 123
    end
    
    it 'should convert to symbol' do
      subject['abc'].should == 123
    end
  end
  
  describe '#[]=' do
    before do
      subject.add(:abc)
    end
    
    it 'should set the value' do
      subject[:abc] = 123
    end
    
    it 'should convert to symbol' do
      subject['abc'] = 123
    end
    
    after do
      subject[:abc].should == 123
    end
  end
  
  describe '#load' do
    let(:yaml) {
      <<-YAML
      development:
        email: bob@example.com
        special_sauce: false
      
      production:
        email: frank@example.com
        special_sauce: false
      YAML
    }
    
    before do
      subject.add(:email)
      subject.add(:special_sauce, :default => true)
    end
    
    it 'should be able to load from YAML' do
      subject.load(yaml, 'development').email.should == 'bob@example.com'
      subject.load(yaml, 'production').email.should == 'frank@example.com'
    end
  end
end