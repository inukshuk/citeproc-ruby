require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Renderer#render_macro' do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Macro.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }

      it 'returns an empty string when empty' do
        expect(renderer.render(item, node)).to eq('')
      end

      it 'renders each child' do
        node << CSL::Style::Text.new(:value => 'foo')
        node << CSL::Style::Text.new(:value => 'bar')

        expect(renderer.render(item, node)).to eq('foobar')
      end

    end

  end
end
