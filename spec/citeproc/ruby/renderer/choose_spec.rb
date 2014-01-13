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

        it 'returns an empty string by default' do
          renderer.render(item, node).should == ''
        end

        describe 'when there is a single nested block' do
          let(:block) do
            CSL::Style::Choose::Block.new do |b|
              b << CSL::Style::Text.new( :term => 'retrieved')
            end
          end

          before(:each) { node << block }

          it 'returns the content of the nested node when the condition evaluates' do
            block[:variable] = 'issue'
            item.data[:issue] = 1
            renderer.render(item, node).should == 'retrieved'
          end

          it 'returns an empty string when the condition does not hold' do
            block[:variable] = 'issue'
            renderer.render(item, node).should == ''
          end
        end
      end

      describe 'Renderer#render_block' do
        let(:node) { CSL::Style::Choose::Block.new }

        it 'returns an empty string by default' do
          renderer.render(item, node).should == ''
        end

        describe 'when there is a text node in the block' do
          before(:each) { node << CSL::Style::Text.new( :term => 'retrieved') }

          it 'returns the content of the nested node when there is no condition' do
            renderer.render(item, node).should == 'retrieved'
          end
        end
      end

      describe 'Renderer#evaluates?' do
        let(:node) { CSL::Style::Choose::Block.new }

        it 'returns true by default (else block)' do
          renderer.evaluates?(item, node).should be_true
        end

        describe 'for variable conditions' do
          before { node[:variable] = 'volume issue' }
          
          it 'returns false unless the item has all variables' do
            renderer.evaluates?(item, node).should be_false
            
            item.data[:volume] = 1
            renderer.evaluates?(item, node).should be_false
            
            item.data[:issue] = 1
            renderer.evaluates?(item, node).should be_true

            item.data[:volume] = nil
            renderer.evaluates?(item, node).should be_false
          end

          describe 'with internal negations' do
            before { node[:variable] = 'volume not:issue' }
            
            it 'returns false unless the item has (or does not have) all variables' do
              renderer.evaluates?(item, node).should be_false

              item.data[:volume] = 1
              renderer.evaluates?(item, node).should be_true

              item.data[:issue] = 1
              renderer.evaluates?(item, node).should be_false

              item.data[:volume] = nil
              renderer.evaluates?(item, node).should be_false
            end
          end

          describe 'and the any-matcher' do
            before { node[:match] = 'any' }

            it 'returns false unless the item has any of the variables' do
              renderer.evaluates?(item, node).should be_false

              item.data[:volume] = 1
              renderer.evaluates?(item, node).should be_true

              item.data[:issue] = 1
              renderer.evaluates?(item, node).should be_true
              
              item.data[:volume] = nil
              renderer.evaluates?(item, node).should be_true
            end
            
            describe 'with internal negations' do
              before { node[:variable] = 'volume not:issue' }

              it 'returns false unless the item has (or does not have) any of the variables' do
                renderer.evaluates?(item, node).should be_true

                item.data[:volume] = 1
                renderer.evaluates?(item, node).should be_true

                item.data[:issue] = 1
                renderer.evaluates?(item, node).should be_true

                item.data[:volume] = nil
                renderer.evaluates?(item, node).should be_false
              end
            end
          end
          
          describe 'and the none-matcher' do
            before { node[:match] = 'none' }

            it 'returns false unless the item has none of the variables' do
              renderer.evaluates?(item, node).should be_true

              item.data[:volume] = 1
              renderer.evaluates?(item, node).should be_false

              item.data[:issue] = 1
              renderer.evaluates?(item, node).should be_false
              
              item.data[:volume] = nil
              renderer.evaluates?(item, node).should be_false
            end
            
            describe 'with internal negations' do
              before { node[:variable] = 'volume not:issue' }

              it 'returns false unless the item has (or does not have) none of the variables' do
                renderer.evaluates?(item, node).should be_false

                item.data[:volume] = 1
                renderer.evaluates?(item, node).should be_false

                item.data[:issue] = 1
                renderer.evaluates?(item, node).should be_false

                item.data[:volume] = nil
                renderer.evaluates?(item, node).should be_true
              end
            end
          end
        end
      end

    end
  end
end
