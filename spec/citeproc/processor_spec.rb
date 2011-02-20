
describe CiteProc::Processor do
  
  before(:each) do
    @proc = CiteProc::Processor.new
  end
  
  describe '#style' do
    
    it 'accepts a style name' do
      @proc.style = 'apa'
      @proc.style.id.should == 'http://www.zotero.org/styles/apa'
    end
  end
  
  describe '#abbreviations' do
    
    it 'can be set and records new abbreviations' do
      expected = { 'default' => { 'container-title' => { 'long' => 'short' } } }
      @proc.abbreviations = expected
      @proc.abbreviations.should == expected
      
      alternate = { 'alternate' => { 'container-title' => { 'long' => 'short' } } }
      @proc.add_abbreviations(alternate)
      @proc.abbreviations.should == expected.merge(alternate)
     
      result = @proc.abbreviate('container-title', 'long')
      result.should == 'short'
      
      result = @proc.abbreviate('container-title', 'long', 'alternate')
      result.should == 'short'
      
      result = @proc.abbreviate('container-title', 'new')
      result.should == 'new'

      result = @proc.abbreviate('container-title', 'new', 'alternate')
      result.should == 'new'

      result = @proc.abbreviate('hereinafter', 'new')
      result.should == 'new'

    end
  end
end