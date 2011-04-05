require 'spec_helper'

describe Support::Attributes do
  
  before(:each) { Object.instance_eval { include Support::Attributes } }
  
  let(:instance) { o = Object.new }
  let(:other) { o = Object.new; o['foo'] = 'bar'; o }
  
  it { should_not be_nil }
  it { should be_empty }
  
  describe '#attributes' do
    
    # before(:all) { class Object; attr_fields :value, %w[ is-numeric punctuation-mode ]; end }

    it 'generates setters for attr_field values' do
      pending
      # lambda { Object.new.is_numeric }.should_not raise_error
    end
    
    it 'generates no other setters' do
      lambda { Object.new.some_other_value }.should raise_error
    end
  end
  
  describe '#merge' do    
    
    it 'merges non-existent values from other object' do
      Object.new.merge(other)['foo'].should == 'bar'
    end
    
    # it 'does not overwrite existing values when merging other object' do
    #   instance.merge(other)['foo'].should == 'bar'
    # end
    
  end
  
end