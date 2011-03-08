module CiteProc

  describe Variable do
    
    describe '#new' do
      it { should_not be_nil }
      
      it 'accepts a string value' do
        Variable.new('test').value.should == 'test'
      end
      
      it 'accepts an attributes hash' do
        Variable.new('value' => 'test').value.should == 'test'
      end
      
      it 'supports self yielding block' do
        Variable.new { |v| v.value = 'test' }.value.should == 'test'
      end
    end
    
    describe '#to_s' do
      it 'displays the value' do
        Variable.new('test').to_s.should == 'test'
      end
    end
    
    describe '#numeric?' do
      it 'returns false by default' do
        Variable.new.should_not be_numeric
      end

      context 'variable holds a number' do
        it 'returns true (string initialized)' do
          Variable.new('23').should be_numeric
        end
        it 'returns true (integer initialized)' do
          Variable.new(23).should be_numeric
        end
      end
      
      context 'variable does not hold a number' do
        it 'returns false for strings' do
          Variable.new('test').should_not be_numeric
          Variable.new('test 23').should_not be_numeric
        end
      end
    end
    
  end
end