module CiteProc
  describe Bibliography do
    
    let(:json) {'[{"test":"test","bibliography-errors":[]},["1","2"]]'}
    
    describe '#new' do
      it { should_not be_nil }
      
      it 'accepts a JSON string' do
        Bibliography.new(json).should_not be_empty
      end
      
      it 'accepts a data array' do
        Bibliography.new([1,2,3]).data.should == [1,2,3]
      end
      
      it 'accepts an options hash' do
        Bibliography.new('test'=>'test').options['test'].should == 'test'
      end
      
      it 'accepts an options hash with errors' do
        Bibliography.new('bibliography-errors'=>[1,2,3]).errors.should == [1,2,3]
      end
    end
    
    describe '#to_json' do
      it 'returns valid JSON when empty' do
        JSON.parse(Bibliography.new.to_json).should_not be_nil
      end
      it 'returns valid JSON with data' do
        JSON.parse(Bibliography.new([1,2,3]).to_json).should_not be_nil
      end
      it 'returns valid JSON with options' do
        JSON.parse(Bibliography.new({'test'=>'test'}).to_json).should_not be_nil
      end
      it 'returns valid JSON with options and data' do
        JSON.parse(Bibliography.new([{'test'=>'test'}, [1,2]]).to_json).should_not be_nil
      end
      it 'supports round-trips' do
        Bibliography.new(json).to_json.should == json
      end
    end
    
  end
end