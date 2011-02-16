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
end