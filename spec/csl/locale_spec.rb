# -*- encoding: utf-8 -*-

module CSL

  describe Locale do

    let(:locale) { Locale.new }

    let(:en) { Locale.new('en-US') }
    let(:de) { Locale.new('de-DE') }
    let(:fr) { Locale.new('fr-FR') }
        
    describe '#new' do
      it { should_not be_nil }
      
      it 'defaults to empty language' do
        locale.language.should be_nil
      end
      
      it 'defaults to empty region' do
        locale.region.should be_nil
      end
    
      it 'contains no terms, date, and options content by default' do
        [:terms, :date, :options].each do |m|
          locale.send(m).should_not be_nil
          locale.send(m).should be_empty
        end
      end

      it 'parses an XML string' do
        locale = Locale.new <<-END
        <locale xml:lang="en">
          <terms>
            <term name="editortranslator" form="short">
              <single>ed. &amp; trans.</single>
              <multiple>eds. &amp; trans.</multiple>
            </term>
          </terms>
        </locale>
        END

        locale.language.should == 'en'
        locale.options.should be_empty
        locale.terms['editortranslator'].pluralize('form' => 'short').should == 'eds. & trans.'
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
        en['book'].should_not be_nil
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
      context 'in English' do
        it 'works' do
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
          result = (1..13).map do |i|
            en.ordinalize(i, 'form' => 'long-ordinal')
          end
      
          expected = %w{ first second third fourth fifth sixth seventh eighth ninth tenth 11th 12th 13th }

          result.should == expected
        end
      end

      context 'in German' do
        it 'works' do
          result = (1..13).map do |i|
            de.ordinalize(i)
          end
      
          expected = %w{ 1. 2. 3. 4. 5. 6. 7. 8. 9. 10. 11. 12. 13. }

          result.should == expected
      
          result = [20, 21, 22, 23, 24, 100, 101, 102, 103, 104, 113, 123].map do |i|
            de.ordinalize(i)
          end

          expected = %w{ 20. 21. 22. 23. 24. 100. 101. 102. 103. 104. 113. 123. }

          result.should == expected

        end
      
        it 'long-forms work' do
          result = (1..13).map do |i|
            de.ordinalize(i, 'form' => 'long-ordinal')
          end
      
          expected = %w{ erster zweiter dritter vierter fünfter sechster siebter achter neunter zehnter  11. 12. 13. }

          result.should == expected
        end
        
        it 'female long-forms work' do
          result = (1..13).map do |i|
            de.ordinalize(i, 'form' => 'long-ordinal', 'gender-form' => 'feminine')
          end
      
          expected = %w{ erste zweite dritte vierte fünfte sechste siebte achte neunte zehnte  11. 12. 13. }

          result.should == expected
        end
        
      end
      
      
    end
  end
end