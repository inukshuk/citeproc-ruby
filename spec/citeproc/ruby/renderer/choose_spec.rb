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
