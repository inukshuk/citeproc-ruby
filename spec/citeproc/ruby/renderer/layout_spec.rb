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
        renderer.render(item, node).should == ''
      end

      describe 'with child nodes' do
        before(:each) do
          node << CSL::Style::Text.new(:value => 'foo')
          node << CSL::Style::Text.new(:value => 'bar')
        end

        it 'renders each child' do
          renderer.render(item, node).should == 'foobar'
        end

        it 'uses the delimiters if specified' do
          node[:delimiter] = '-'
          renderer.render(item, node).should == 'foo-bar'
        end
      end

    end

  end
end

