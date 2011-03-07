module CSL

  describe Term do

    let(:xml) { '<term name="test" gender="neutral"><single>test</single><multiple>tests</multiple></term>' }
    let(:hash) { { 'long' => { 'singular' => 'test', 'plural' => 'tests' } } }
    
    describe '#new' do
      it 'defaults to an empty string' do
        Term.new.to_s.should be_empty
      end
      
      it 'parses an XML string' do
        Term.new(xml).to_s.should == 'test'
      end

      it 'parses a hash' do
        Term.new(hash).to_s.should == 'test'
      end
      
      it 'supports a self yielding block' do
        Term.new do |t|
          t['long'] = { 'singular' => 'test', 'plural' => 'tests' }
        end.to_s.should == 'test'
      end
    end
    
    describe '#pluralize' do
      it 'returns the terms plural form' do
        Term.new(hash).pluralize.should == 'tests'
      end
    end

    describe '#singularize' do
      it 'returns the terms singular form' do
        Term.new(hash).singularize.should == 'test'
      end
    end

    describe 'gender' do
      it 'parses the gender attribute' do
        Term.new(xml).should have_gender
        Term.new(xml).should be_neutral
        Term.new(xml).should_not be_masculine
        Term.new(xml).should_not be_feminine
      end

      it 'has no gender by default' do
        Term.new.should_not have_gender
        Term.new(hash).should_not have_gender
      end
      
    end
  end
  
end