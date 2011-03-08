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
  
end