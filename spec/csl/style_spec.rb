module CSL

  describe Style do
  
    let(:style) { Style.new }
    let(:apa) { Style.new.open('apa') }
    
    describe '#open' do
      it 'accepts a style name' do
        style.open('apa').id.should_not be_empty
      end
    
      it 'accepts a filename' do
        style.open(File.expand_path('../../../resource/style/apa.csl', __FILE__)).id.should_not be_empty
      end

      it 'accepts an inline style' do
        style.open(File.read(File.expand_path('../../../resource/style/apa.csl', __FILE__))).id.should_not be_empty
      end

      # -- requires internet connection
      # it 'accepts an URI' do
      #   style.open 'http://www.zotero.org/styles/apa'
      #   style.id.should == 'http://www.zotero.org/styles/apa'
      # end
    
    end
  
    describe 'info' do
      it 'returns id, title, and link information' do
        # style.id.should == 'http://www.zotero.org/styles/apa'
        # style.link.should == 'http://www.zotero.org/styles/apa'
        apa.title.should == 'American Psychological Association'
      end
    end
  
    describe 'macros' do
      it 'initialises a macros hash' do
        apa.macros.keys.sort.should == ["access", "author", "author-short", "citation-locator", "container-contributors", "edition", "event", "issued", "issued-year", "locators", "publisher", "secondary-contributors", "title"]
        apa.macros.values.map(&:class).uniq.should == [CSL::Nodes::Macro]
      end
    end
  
    describe 'citation renderer' do
      it 'initialises the citation renderer' do
        apa.citation.respond_to?(:process)
      end
    
      it 'contains a layout section' do
        apa.citation.layout.should_not == nil
      end
    
    end

    describe 'bibliography renderer' do
      it 'initialises the bibliography renderer' do
        apa.bibliography.should_not == nil
      end
    end
  
  end
end