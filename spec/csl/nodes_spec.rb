# encoding: utf-8

describe CSL::Text do
  
  before(:each) do
    @style = CSL::Style.new
    @locale = CSL::Locale.new
  end
  
  
  it 'can be created' do
    xml = '<text/>'
    text = CSL::Text.new(Nokogiri::XML(xml).root, @style)
    text.should_not be nil
    text.variable?.should be false
    text.macro?.should be false
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
        item = CSL::Item.new
        text = CSL::Text.new(Nokogiri::XML(t).root, @style)
        [text.term?, text.term, text.form?, text.form, text.plural?, text.plural]
      }.flatten

      result.should == expected
    end
  end
  
  describe 'processing' do
    it 'returns an empty string by default' do
      xml = '<text/>'
      item = CSL::Item.new
      text = CSL::Text.new(Nokogiri::XML(xml).root, @style)
      text.process(item, @locale).should == ''
    end
    
    it 'handles terms correctly' do
      xml = [
        '<text term="editorial-director" plural="false" />',
        '<text term="editorial-director" plural="true" />',
        '<text term="section" form="symbol" plural="false" />',
        '<text term="section" form="symbol" plural="true" />']

      expected = [ 'editor', 'editors', '§', '§§' ]
      
      result = xml.map { |t|
        item = CSL::Item.new
        text = CSL::Text.new(Nokogiri::XML(t).root, @style)
        text.process(item, @locale)
      }
      
      result.should == expected
    end
    
  end
end