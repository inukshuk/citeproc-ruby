require 'spec_helper'

module CiteProc
  module Ruby
    describe 'Conditional Rendering Elements' do
      let(:renderer) { Renderer.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }
      
      describe 'Renderer#render_choose' do
        let(:node) { CSL::Style::Choose.new }

      end

      describe 'Renderer#render_block' do
        let(:node) { CSL::Style::Choose::Block.new }

      end

      describe 'Renderer#evaluates?' do
        let(:node) { CSL::Style::Choose::Block.new }

        it 'returns true by default (else block)' do
          renderer.evaluates?(item, node).should be_true
        end
        
      end

    end
  end
end
