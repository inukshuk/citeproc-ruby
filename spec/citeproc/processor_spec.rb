require 'spec_helper'

module CiteProc
  describe Processor do

    let(:cp) { Processor.new :style => 'apa' }

    describe '#render' do

      it 'renders the item in bibliography mode by default' do
        cp.render(items(:grammatology)).should == 'Derrida, J. (1976). Of Grammatology. Baltimore: Johns Hopkins University Press.'
      end
    end

  end
end
