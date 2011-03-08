module CiteProc

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