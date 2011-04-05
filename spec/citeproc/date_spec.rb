require 'spec_helper'

module CiteProc

  describe Date do
    
    describe '#new' do
      it { should_not be_nil }
    end
    
    describe '.create' do
      it 'should accept parameters and return a new instance' do
        Date.create('date-parts' => [[2001, 1]]).year.should == 2001
      end
    end
    
    describe '#sort' do
      
      let(:ad2k) { Date.create('date-parts' => [[2000]])}
      let(:may) { Date.create('date-parts' => [[2000, 5]])}
      let(:first_of_may) { Date.create('date-parts' => [[2000, 5, 1]])}
      
      let(:bc100) { Date.create('date-parts' => [[-100]]) }
      let(:bc50) { Date.create('date-parts' => [[-50]]) }
      let(:ad50) { Date.create('date-parts' => [[50]]) }
      let(:ad100) { Date.create('date-parts' => [[100]]) }

      it 'dates with more date-parts will come after those with fewer parts' do
        (ad2k < may  && may < first_of_may).should be true
      end
      
      it 'negative years are sorted inversely' do
        [ad50, bc100, bc50, ad100].sort.map(&:year).should == [-100, -50, 50, 100]
      end
    end
    
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
    end

    describe 'literal dates' do
      
      it 'is not literal by default' do
        Date.new.should_not be_literal
      end
      
      it 'is literal if it contains only a literal field' do
        Date.create(:literal => 'foo').should be_literal
      end
      
      it 'is literal if it contains a literal field' do
        Date.create('date-parts' => [[2000]], :literal => 'foo').should be_literal
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