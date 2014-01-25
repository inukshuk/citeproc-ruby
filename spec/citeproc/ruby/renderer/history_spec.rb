require 'spec_helper'

module CiteProc
  module Ruby

    describe Renderer::RenderHistory do
      let(:history) { Renderer::RenderHistory.new nil, 3 }

      it 'has an empty citation history' do
        history.citation.should == []
      end

      it 'has an empty bibliography history' do
        history.citation.should == []
      end

      describe '#remember!' do
        it 'saves the passed in items' do
          lambda {
            history.remember! :citation, 1
          }.should change { history.citation }.to([[1]])
        end

        it 'drops remembered items when they are too old' do
          lambda {
            history.remember! :citation, 1
            history.remember! :citation, 2
            history.remember! :citation, 3
            history.remember! :citation, 4
          }.should change { history.citation }.to([[4], [3], [2]])
        end
      end
    end

  end
end
