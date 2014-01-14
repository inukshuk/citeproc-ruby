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

        it 'fails if there is an unknown condition type' do
          node.stub(:conditions).and_return([[:unknown, :all?, 'x']])
          lambda { renderer.evaluates?(item, node) }.should raise_error
        end

        it 'returns false for disambiguate (implementation pending)' do
          node[:disambiguate] = true
          renderer.evaluates?(item, node).should be_false
        end

        it 'returns false for position (implementation pending)' do
          node[:position] = 'first'
          renderer.evaluates?(item, node).should be_false
        end

        describe 'for is-numeric conditions' do
          before { node[:'is-numeric'] = 'note archive' }

          it 'returns false unless all variables are numeric' do
            renderer.evaluates?(item, node).should be_false
            
            item.data[:archive] = 1
            renderer.evaluates?(item, node).should be_false
            
            item.data[:note] = 'L2d'
            renderer.evaluates?(item, node).should be_true

            item.data[:archive] = 'second'
            renderer.evaluates?(item, node).should be_false
          end
        end

        describe 'for is-uncertain-date conditions' do
          before { node[:'is-uncertain-date'] = 'issued' }

          it 'returns false unless all variables contain uncertain dates' do
            renderer.evaluates?(item, node).should be_false
            
            item.data[:issued] = 2012
            renderer.evaluates?(item, node).should be_false
            
            item.data[:issued].uncertain!
            renderer.evaluates?(item, node).should be_true
          end
        end

        describe 'for locator conditions' do
          before { node[:locator] = 'figure book sub-verbo' }

          it 'returns false unless the locator matches all of the given locators' do
            renderer.evaluates?(item, node).should be_false
            
            item.locator = :book
            renderer.evaluates?(item, node).should be_false
            
            item.locator = 'volume'
            renderer.evaluates?(item, node).should be_false

            item.locator = 'figure'
            renderer.evaluates?(item, node).should be_false
          end

          describe 'when the match attribute is set to "any"' do
            before { node[:match] = 'any' }

            it 'returns false unless the locator matches any of the given locators' do
              renderer.evaluates?(item, node).should be_false
              
              item.locator = :book
              renderer.evaluates?(item, node).should be_true
              
              item.locator = 'volume'
              renderer.evaluates?(item, node).should be_false

              item.locator = 'figure'
              renderer.evaluates?(item, node).should be_true
            end

            it 'matches "sub verbo" as "sub-verbo"' do
              item.locator = 'sub-verbo'
              renderer.evaluates?(item, node).should be_true

              item.locator = 'sub verbo'
              renderer.evaluates?(item, node).should be_true
            end
          end
        end

        describe 'for type conditions' do
          before { node[:type] = 'book treaty' }

          it 'returns false unless the type matches all of the given types' do
            renderer.evaluates?(item, node).should be_false
            
            item.data[:type] = :book
            renderer.evaluates?(item, node).should be_false
            
            item.data[:type] = 'article'
            renderer.evaluates?(item, node).should be_false

            item.data[:type] = 'treaty'
            renderer.evaluates?(item, node).should be_false
          end

          describe 'when the match attribute is set to "any"' do
            before { node[:match] = 'any' }

            it 'returns false unless the locator matches any of the given locators' do
              renderer.evaluates?(item, node).should be_false
              
              item.data[:type] = :book
              renderer.evaluates?(item, node).should be_true
              
              item.data[:type] = 'article'
              renderer.evaluates?(item, node).should be_false

              item.data[:type] = 'treaty'
              renderer.evaluates?(item, node).should be_true
            end
          end
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
