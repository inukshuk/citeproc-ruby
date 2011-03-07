module CSL
  class Nodes
  
    describe Nodes do

      let(:style) { Style.new }
      let(:locale) { CSL.default_locale }

      let(:node) { Node.new('<node/>') }
      
      describe '#new' do
        it 'parses an xml node' do
          node.nil?.should_not be true
        end
        
        it 'supports multiple arguments' do
          n = Node.new(node, style, '<node/>')
          n.parent.should == node
          n.style.should == style
        end
        
        it 'parses child elements' do
          child = Node.new('<node><node/></node>', node)
          child.parent.should == node
          child.children.length.should == 1
          child.children.first.parent.should == child
        end
        
        it 'pushes style to children' do
          child = Node.new('<node><node/></node>', style)
          child.children.first.style.should == style
        end
        
        it 'supports a self yielding block' do
          Node.new { |n| n.parent = node }.parent.should == node
        end
        
        it 'accepts an attributes hash' do
          Node.new('foo' => 'bar')['foo'].should == 'bar'
        end
      end
      
      
      describe Text do  
  
        describe '#new' do
          it 'parses an xml node' do
            Text.new('<text/>', style).nil?.should_not be true
          end
  
        end
      
        describe 'attributes' do
          it 'are initialised correctly' do
            xml = [
              '<text term="editorial-director" plural="false" />',
              '<text term="editorial-director" plural="true" />',
              '<text term="section" form="symbol" plural="false" />',
              '<text term="section" form="symbol" plural="true" />']

            expected = [true, 'editorial-director', false, nil, false, 'false',
              true, 'editorial-director', false, nil, true, 'true',
              true, 'section', true, 'symbol', false, 'false',
              true, 'section', true, 'symbol', true, 'true']

            result = xml.map { |t|
              item = CiteProc::Item.new
              text = CSL::Nodes::Text.new(Nokogiri::XML(t).root, @style)
              [text.term?, text.term, text.form?, text.form, text.plural?, text.plural]
            }.flatten

            result.should == expected
          end
        end
    
      end

      describe Number do

        describe '#new' do

          it { should_not be_nil }
        
          it 'parses an XML node' do
            number = Number.new('<number/>', style)
            number.should_not be_nil
            number.style.should_not be_nil
            number.form?.should be false
            number.variable?.should be false
          end
        end
    
      end
    
      describe Date do
        let(:date) { Date.new }
        
        describe '#new' do
          it { should_not be_nil }
        end
      
        describe '#merge_parts' do
          it 'merges two empty lists' do
            date.merge_parts([], []).should be_empty
          end
        
          it 'merges an empty list and a list of date-parts' do
            date.merge_parts([], locale.date['text']).should be_empty
          end

          it 'merges a list of date-parts and an empty list' do
            date.merge_parts(locale.date['text'], []).map(&:to_s).should == locale.date['text'].map(&:to_s)
          end

          it 'merges a list of date-parts with itself' do
            date.merge_parts(locale.date['text'], locale.date['text']).map(&:to_s).should == locale.date['text'].map(&:to_s)
          end
          
          it 'filters according to the date-parts attribute' do
            date.date_parts = 'year'
            date.merge_parts(locale.date['text'], []).should have(1).part
            date.date_parts = 'month-day'
            date.merge_parts(locale.date['text'], []).should have(2).parts
          end
          
          it 'copies attribute values' do
            date.merge_parts([DatePart.new({'name' => 'year'})], [DatePart.new({'name' => 'year', 'foo' => 'bar'})]).first['foo'].should == 'bar'
          end
        end
      
        describe '#date_parts' do
          it 'returns year-month-day by default' do
            date.date_parts.should == 'year-month-day'
          end
        end
        
      end
    end
  end
end