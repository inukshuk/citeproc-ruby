module CiteProc
  describe Selector do
    describe '#new' do
      it { should_not be_nil }

      %w{ all any none select include exclude }.each do |mode|
        it "accepts string/symbol values (#{mode})" do
          Selector.new(mode).type.should_not be_nil
          # Selector.new(mode.to_sym).type.should_not be_nil
        end
      end
      
      describe 'json API support' do
      
        it 'accepts a json object (select)' do
          Selector.new(
             "select" => [
                {
                   "field" => "type",
                   "value" => "book"
                },
                {  "field" => "categories",
                    "value" => "1990s"
                }
             ]
          ).select.should have(2).items
        end

        it 'accepts a json string (select)' do
          Selector.new('{
             "select" : [
                {
                   "field" : "type",
                   "value" : "book"
                },
                {  "field" : "categories",
                    "value" : "1990s"
                }
             ]
          }
          ').select.should have(2).items
        end
        
      end
    end
    
    describe '#conditions' do
    
      let(:condition) { {'field' => 'type', 'value' => 'book'} }
      
      %w{ select include exclude }.each do |mode|
        it "returns the conditions (#{mode})" do
          Selector.new(mode => [condition]).conditions.should == [condition]
        end
      end
    
    end
    
    describe '#to_proc' do
      
      let(:books) { Selector.new('select' => [{'field' => 'type', 'value' => 'book'}]) }
      let(:english_books) { Selector.new('select' => [{'field' => 'type', 'value' => 'book'}, {'field' => 'language', 'value' => 'en'}]) }
      
      
      it 'can be used as a block to Array#select' do
        [{ 'type' => 'book'}, { 'type' => 'article'}].select(&books).should have(1).item
      end
      
      it 'does not filter out anything by default' do
        [1,2,3].select(&Selector.new).should == [1,2,3]
      end
      
      describe 'when the type is :select' do
        it 'selects items that match all conditions' do
          [{ 'type' => 'book'}, { 'type' => 'article'}, { 'type' => 'book', 'language' => 'en'}].select(&english_books).should have(1).item          
        end
      end
      
    end
    
  end
end