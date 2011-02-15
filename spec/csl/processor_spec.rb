describe CSL::Processor do
  
  before(:each) do
    @proc = CSL::Processor.new
  end
  
  describe '#style' do
    
    it 'accepts a style name' do
      @proc.style = 'apa'
      @proc.style.id == 'http://www.zotero.org/styles/apa'
    end
  end
  
  describe "CSL Processor Tests" do
    it 'passes tests' do
      tests = CSL::Tests.load(:processor)
      @proc.style = tests[0]['csl']
      @proc.register(tests[0]['input'])
      puts @proc.registry['ITEM-1'].inspect
    end
  end
end