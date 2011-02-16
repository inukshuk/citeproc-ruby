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

describe CSL::Number do
  
  before(:each) do
    @style = CSL::Style.new
    @locale = CSL::Locale.new
    @item = CSL::Item.new do |item|
      item.issue = 1
      item.volume = 2
      item.edition = 3
      item.number = 23
    end
  end
  
  
  it 'can be created' do
    xml = '<number/>'
    number = CSL::Number.new(Nokogiri::XML(xml).root, @style)
    number.should_not be nil
    number.form?.should be false
    number.variable?.should be false
  end

  describe 'processing' do
    it 'returns an empty string by default' do
      xml = '<number/>'
      number = CSL::Number.new(Nokogiri::XML(xml).root, @style)
      number.process(@item, @locale).should == ''
    end
  
    it 'supports variables and return numeric value by default' do
      xml = '<number variable="edition"/>'
      number = CSL::Number.new(Nokogiri::XML(xml).root, @style)
      number.process(@item, @locale).should == '3'
    end

    it 'supports ordinals and roman numbers' do
      xml = [
        '<number variable="issue" form="ordinal"/>',
        '<number variable="volume" form="ordinal"/>',
        '<number variable="edition" form="ordinal"/>',
        '<number variable="number" form="ordinal"/>',
        '<number variable="issue" form="long-ordinal"/>',
        '<number variable="volume" form="long-ordinal"/>',
        '<number variable="edition" form="long-ordinal"/>',
        '<number variable="issue" form="roman"/>',
        '<number variable="volume" form="roman"/>',
        '<number variable="edition" form="roman"/>',
        '<number variable="number" form="roman"/>']
        
      expected = %w{ 1st 2nd 3rd 23rd first second third i ii iii xxiii }
      
      result = xml.map do |n|
        number = CSL::Number.new(Nokogiri::XML(n).root, @style)
        number.process(@item, @locale)
      end
      
      result.should == expected
    end
  
  end
end