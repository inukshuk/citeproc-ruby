require 'spec_helper'

module CiteProc
  module Ruby

    describe Renderer::History do
      let(:state) { Renderer::State.new }
      let(:history) { state.history }

      it 'has an empty citation history' do
        history.memory['citation'].should == []
      end

      it 'has an empty bibliography history' do
        history.memory['bibliogrpahy'].should == []
      end

      describe '#update' do
        it 'saves the passed in items for :store!' do
          lambda {
            history.update :store!, 'citation', { :x => 1 }
          }.should change { history.citation }.to([{ :x => 1 }])
        end

        it 'drops remembered items when they are too old' do
          lambda {
            history.update :store!, 'citation', { :x => 1 }
            history.update :store!, 'citation', { :x => 2 }
            history.update :store!, 'citation', { :x => 3 }
            history.update :store!, 'citation', { :x => 4 }
            history.update :store!, 'citation', { :x => 5 }
          }.should change { history.citation.length }.to(3)
        end
      end

      describe '#discard' do
        it 'clears the history' do
          history.update :store!, 'bibliography', { :x => 1 }
          history.memory.should_not be_empty
          history.discard
          history.memory.should be_empty
        end
      end
    end

  end
end
