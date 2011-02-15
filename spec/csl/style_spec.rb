describe CSL::Style do
  
  before(:each) do
    @style = CSL::Style.new
  end
  
  describe '#open' do
    
    it 'accepts a style name' do
      @style.open 'apa'
      @style.id.should == 'http://www.zotero.org/styles/apa'
    end
    
    it 'accepts a filename' do
      @style.open File.expand_path('../../../resource/style/apa.csl', __FILE__)
      @style.id.should == 'http://www.zotero.org/styles/apa'
    end

    it 'accepts an inline style' do
      @style.open File.read(File.expand_path('../../../resource/style/apa.csl', __FILE__))
      @style.id.should == 'http://www.zotero.org/styles/apa'
    end

    it 'accepts an URI' do
      @style.open 'http://www.zotero.org/styles/apa'
      @style.id.should == 'http://www.zotero.org/styles/apa'
    end
    
  end
  
  describe 'info' do
    it 'returns id, title, and link information' do
      @style.open 'apa'
      @style.id.should == 'http://www.zotero.org/styles/apa'
      @style.link.should == 'http://www.zotero.org/styles/apa'
      @style.title.should == 'American Psychological Association'
    end
  end
  
  describe 'macros' do
    it 'initialises a macros hash' do
      @style.open 'apa'
      @style.macros.keys.sort.should == ["access", "author", "author-short", "citation-locator", "container-contributors", "edition", "event", "issued", "issued-year", "locators", "publisher", "secondary-contributors", "title"]
    end
  end
end