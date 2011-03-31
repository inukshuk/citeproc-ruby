module CSL
  describe Node do
    
    describe 'CSL.Node utility function' do
      # it 'returns a new Node from an empty Hash' do
      #   CSL.Node({}).should_not be_nil
      # end
    end
    
    describe '#new' do
      it { should_not be_nil }
    end
    
    describe '.create' do
      it 'accepts an empty hash and returns a new Node' do
        Node.create({}).is_a?(Node).should be true
      end
      
      it 'creates a new node with the given parameters' do
        Node.create(:foo => 'foo')[:foo].should == 'foo'
      end
    end
    
  end
end