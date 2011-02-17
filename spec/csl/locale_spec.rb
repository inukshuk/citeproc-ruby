describe CSL::Locale do

  describe '#new' do
    it 'defaults to English' do
      locale = CSL::Locale.new
      locale.language.should == 'en'
      locale.region.should == 'US'
    end
    
    it 'contains terms, date, and options content by default' do
      locale = CSL::Locale.new
      [:terms, :date].each do |m|
        locale.send(m).nil?.should_not be true
        locale.send(m).empty?.should_not be true
      end
      locale.options.nil?.should_not be true
    end

  end
  
  describe '#set' do
    it 'sets a new language (and default region)' do
      locale = CSL::Locale.new
      language = 'de'
      
      locale.language = language
      locale.language.should == language
      locale.region.should_not == 'US'
      
      locale = CSL::Locale.new
      locale.set(language)
      locale.language.should == language
      locale.region.should_not == 'US'      
    end
    
    it 'sets a new language and region' do
      locale = CSL::Locale.new
      language = 'de'
      region = 'DE'
      
      locale.region = region
      locale.language.should == language
      locale.region.should == region
      
      locale = CSL::Locale.new
      locale.set([language, region].join('-'))
      locale.language.should == language
      locale.region.should == region
    end
    
  end
  
  describe '#terms' do
    it 'contains common terms by default' do
      locale = CSL::Locale.new
      locale['book'].nil?.should_not be true
    end
    
    it 'contains variants for form and number' do
      locale = CSL::Locale.new
      locale['page']['long'] == ['page', 'pages']
      locale['page']['short'].should == ['p.', 'pp.']
    end
    
    it 'returns different values for different languages' do
      [CSL::Locale.new, CSL::Locale.new('de-DE'), CSL::Locale.new('fr')].map do |locale|
        locale['editor'].to_s
      end.uniq.length.should == 3
    end
  end
  
  describe '#ordinalize' do
    it 'works in English' do
      locale = CSL::Locale.new
      
      result = (1..13).map do |i|
        locale.ordinalize(i)
      end
      
      expected = %w{ 1st 2nd 3rd 4th 5th 6th 7th 8th 9th 10th 11th 12th 13th }

      result.should == expected
      
      result = [20, 21, 22, 23, 24, 100, 101, 102, 103, 104].map do |i|
        locale.ordinalize(i)
      end

      expected = %w{ 20th 21st 22nd 23rd 24th 100th 101st 102nd 103rd 104th }

      result.should == expected

      result = (1..10).map do |i|
        locale.ordinalize(i, 'form' => 'long-ordinal')
      end
      
      expected = %w{ first second third fourth fifth sixth seventh eighth ninth tenth }

      result.should == expected
    end
  end
end