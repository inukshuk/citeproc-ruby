module CSL

  describe Locale do

    let(:locale) { Locale.new }

    let(:en) { Locale.new('en-US') }
    let(:de) { Locale.new('de-DE') }
    let(:fr) { Locale.new('fr-FR') }
        
    describe '#new' do
      it 'defaults to empty language, region' do
        locale.language.should be nil
        locale.region.should be nil
      end
    
      it 'contains no terms, date, and options content by default' do
        [:terms, :date, :options].each do |m|
          locale.send(m).nil?.should_not be true
          locale.send(m).empty?.should be true
        end
      end

      it 'parses an XML string' do
        l = Locale.new <<-END
        <locale xml:lang="en">
          <terms>
            <term name="editortranslator" form="short">
              <single>ed. &amp; trans.</single>
              <multiple>eds. &amp; trans.</multiple>
            </term>
          </terms>
        </locale>
        END

        l.language.should == 'en'
        l.options.empty?.should be true
        l.terms['editortranslator'].pluralize('form' => 'short').should == 'eds. & trans.'
      end
    end
  
    describe '#set' do
      it 'sets a new language' do
        language = 'de'
      
        locale.language = language
        locale.language.should == language
        locale.region.should == 'DE'      
      end
    
      it 'sets a new language and region' do
        language = 'de'
        region = 'DE'
      
        locale.region = region
        locale.language.should == language
        locale.region.should == region
      end
    
    end
  
    describe '#terms' do
      it 'contains common terms by default' do
        en['book'].nil?.should_not be true
      end
    
      it 'contains variants for form and number' do
        en['page']['long'].values.should == ['page', 'pages']
        en['page']['short'].values.should == ['p.', 'pp.']
      end
    
      it 'returns different values for different languages' do
        [en, de, fr].map do |l|
          l['editor'].to_s
        end.uniq.length.should == 3
      end
    end
  
    describe '#ordinalize' do
      it 'works in English' do
        result = (1..13).map do |i|
          en.ordinalize(i)
        end
      
        expected = %w{ 1st 2nd 3rd 4th 5th 6th 7th 8th 9th 10th 11th 12th 13th }

        result.should == expected
      
        result = [20, 21, 22, 23, 24, 100, 101, 102, 103, 104, 113, 123].map do |i|
          en.ordinalize(i)
        end

        expected = %w{ 20th 21st 22nd 23rd 24th 100th 101st 102nd 103rd 104th 113th 123rd }

        result.should == expected

      end
      
      it 'long-forms work in English' do
        result = (1..10).map do |i|
          en.ordinalize(i, 'form' => 'long-ordinal')
        end
      
        expected = %w{ first second third fourth fifth sixth seventh eighth ninth tenth }

        result.should == expected
      end
      
    end
  end
end