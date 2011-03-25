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

    describe '#to_i' do
      it 'returns zero by default' do
        Variable.new.to_i.should == 0
      end
      
      context 'when the value is numeric' do
        %w{ -23 -1 0 1 23 }.each do |value|
          it "returns the integer value (#{value})" do
            Variable.new(value).to_i.should == value.to_i
          end
        end
        
        it 'returns only the first numeric value if there are several' do
          Variable.new('testing 1, 2, 3...').to_i.should == 1
        end
      end
    end

    
    describe '#numeric?' do
      it 'returns false by default' do
        Variable.new.should_not be_numeric
      end

      context 'variable contains a number' do
        it 'returns true (string initialized)' do
          Variable.new('23').should be_numeric
          Variable.new('foo 23').should be_numeric
        end
        it 'returns true (integer initialized)' do
          Variable.new(23).should be_numeric
        end
      end
      
      context 'variable does not contain a number' do
        it 'returns false for strings' do
          Variable.new('test').should_not be_numeric
        end
      end
    end
    
  end
end