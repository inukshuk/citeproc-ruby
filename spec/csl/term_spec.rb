module CSL

  describe Term do

    let(:locale) { Locale.new }
    let(:xml) { '<term name="test" gender="neutral"><single>test</single><multiple>tests</multiple></term>' }
    let(:hash) { { 'long' => { 'singular' => 'test', 'plural' => 'tests' } } }
    
    describe '#new' do
      it 'defaults to an empty string' do
        Term.new.to_s.should == ''
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
      Term.new(xml).has_gender?.should_be true
    end
  end
  
end