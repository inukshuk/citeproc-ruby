describe Support::Attributes do
  
  before(:each) { Object.instance_eval { include Support::Attributes } }
  
  subject { Object.new }
  
  it { should_not be_nil }
  it { should be_empty }
  
  describe '#attributes' do
    
    # before(:all) { class Object; attr_fields :value, %w[ is-numeric punctuation-mode ]; end }

    it 'generates setters for attr_field values' do
      pending
      # lambda { Object.new.is_numeric }.should_not raise_error
    end
    
    it 'generates no other setters' do
      lambda { subject.some_other_value }.should raise_error
    end
  end
  
end