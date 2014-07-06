require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Renderer#render_layout' do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Layout.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }

      it 'returns an empty string when empty' do
        expect(renderer.render(item, node)).to eq('')
      end

      describe 'with child nodes' do
        before(:each) do
          node << CSL::Style::Text.new(:value => 'foo')
          node << CSL::Style::Text.new(:value => 'bar')
        end

        it 'renders each child' do
          expect(renderer.render(item, node)).to eq('foobar')
        end

        it 'uses the delimiters if specified' do
          node[:delimiter] = '-'
          expect(renderer.render(item, node)).to eq('foo-bar')
        end
      end

    end

  end
end

