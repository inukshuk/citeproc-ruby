require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Renderer#render_text' do
      let(:renderer) { Renderer.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }
      
      describe 'given an empty text node' do
        let(:node) { CSL::Style::Text.new }
        
        it 'returns an empty string for an empty item' do
          renderer.render_text(item, node).should == ''
        end
        
        it 'returns an empty string for an item with variables' do
          item.data.title = 'foo'
          renderer.render_text(item, node).should == ''
        end
      end

      describe 'given a text node with a value' do
        let(:node) { CSL::Style::Text.new(:value => 'foobar') }
        
        it 'returns the value for an empty item' do
          renderer.render_text(item, node).should == 'foobar'
        end
        
        it 'returns the value for an item with variables' do
          item.data.title = 'foo'
          renderer.render_text(item, node).should == 'foobar'
        end
      end

      describe 'given a text node with a variable' do
        let(:node) { CSL::Style::Text.new(:variable => 'title') }
        
        it 'returns an empty strong for an empty item' do
          renderer.render_text(item, node).should == ''
        end

        it 'returns an empty strong for an item with no matching variable' do
          item.data.publisher = 'the full title'
          renderer.render_text(item, node).should == ''
        end
        
        it "returns the variable's value for an item with a matching variable" do
          item.data.title = 'the full title'
          renderer.render_text(item, node).should == 'the full title'
        end
        
        describe 'when the form attribute is set to :short' do
          before(:each) {
            item.data.title = 'the full title'
            node[:form] = :short
          }
          
          it "prefers the short version if available" do
            item.data.title_short = 'the short title'
            renderer.render_text(item, node).should == 'the short title'
          end
          
          it "falls back to the variable if unavailable" do
            renderer.render_text(item, node).should == 'the full title'
          end
        end
      end

      describe 'given a text node with a variable' do
        let(:node) { CSL::Style::Text.new(:term => 'anonymous') }
        
        it "returns the term's long form by default" do
          renderer.render_text(item, node).should == 'anonymous'
        end
        
        describe 'when the form attribute is set to :short' do
          before(:each) { node[:form] = 'short' }
          
          it "returns the term's short form by default" do
            renderer.render_text(item, node).should == 'anon.'
          end
          
          it 'falls back to the long version if there is no short version' do
            node[:term] = 'et-al'
            renderer.render_text(item, node).should == 'et al.'
          end
        end
      end
      
    end

  end
end
