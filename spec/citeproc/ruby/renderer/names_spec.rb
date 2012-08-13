require 'spec_helper'

module CiteProc
  module Ruby

    describe "Renderer#render_names" do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Number.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }

      describe 'given an empty node' do
        # it 'returns an empty string for an empty item' do
        #   renderer.render_names(item, node).should == ''
        # end
        # 
        # it 'returns an empty string for an item with variables' do
        #   item.data.edition = 'foo'
        #   renderer.render_names(item, node).should == ''
        # end
      end

    end
    
  end
end
