require 'spec_helper'

module CiteProc
  module Ruby

    describe "Renderer#render_label" do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Label.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }

      describe 'given an empty node' do
        it 'returns an empty string for an empty item' do
          renderer.render_label(item, node).should == ''
        end

        it 'returns an empty string for an item with variables' do
          item.data.edition = 'foo'
          renderer.render_label(item, node).should == ''
        end
      end

      describe "when the node's variable is set to :page" do
        before(:each) { node[:variable] = :page }
        
        describe "for an item with no page value" do
          it 'returns an empty string' do
            renderer.render_label(item, node).should == ''
          end
        end

        describe "for an item with no page value" do
          it 'returns the singular label for a number' do
            item.write_attribute :page, '23'
            renderer.render_label(item, node).should == 'p.'
          end
        end

        
      end
    end
    
  end
end
