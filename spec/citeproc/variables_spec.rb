module CiteProc
  describe Name do
    Test::Fixtures::Names.keys.each do |feature|
      describe feature do

        Test::Fixtures::Names[feature].each do |test|

          it test['it'] do
            names = test['names'].map { |name| Name.new(name) }
            expected = test['expected']
            options = test['options']
        
            result = case feature
              when 'sort'
                names.sort.map(&:to_s)
              else
                names.map { |name| name.send(feature, options) }
              end
        
            result.should == expected 
          end
        
        end
      
      end
    end
  end
  
  describe Date do
    Test::Fixtures::Dates.keys.each do |feature|

      describe feature do
        Test::Fixtures::Dates[feature].each do |example|

          it example['it'] do
            dates = example['dates'].map { |date| Date.new(date) }
            expected = example['expected']
            options = example['options']

            result = case feature
              when 'display'
                dates.map { |date| date.display(options) }
              when 'json-api'
                dates.map(&:to_json)
              end
            
            result.should == expected
          end  

        end
      end

      describe 'uncertain dates' do
        it 'are uncertain' do
          Date.new({ 'date-parts' => [[-225]], 'circa' => '1' }).should be_uncertain
          Date.new { |d| d.parts = [[-225]]; d.circa = true }.should be_uncertain
        end
      end
    end
    
  end
  
end