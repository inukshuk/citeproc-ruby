
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
  
end