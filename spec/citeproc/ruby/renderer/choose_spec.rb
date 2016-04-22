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
          expect(renderer.render(item, node)).to eq('')
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
            expect(renderer.render(item, node)).to eq('retrieved')
          end

          it 'returns an empty string when the condition does not hold' do
            block[:variable] = 'issue'
            expect(renderer.render(item, node)).to eq('')
          end
        end
      end

      describe 'Renderer#render_block' do
        let(:node) { CSL::Style::Choose::Block.new }

        it 'returns an empty string by default' do
          expect(renderer.render(item, node)).to eq('')
        end

        describe 'when there is a text node in the block' do
          before(:each) { node << CSL::Style::Text.new( :term => 'retrieved') }

          it 'returns the content of the nested node when there is no condition' do
            expect(renderer.render(item, node)).to eq('retrieved')
          end
        end
      end

      describe 'Renderer#evaluates?' do
        let(:node) { CSL::Style::Choose::Block.new }

        it 'returns true by default (else block)' do
          expect(renderer.evaluates?(item, node)).to be_truthy
        end

        it 'fails if there is an unknown condition type' do
          allow(node).to receive(:conditions).and_return([[:unknown, :all?, 'x']])
          expect { renderer.evaluates?(item, node) }.to raise_error(RuntimeError)
        end

        it 'returns false for disambiguate (implementation pending)' do
          node[:disambiguate] = true
          expect(renderer.evaluates?(item, node)).to be_falsey
        end

        it 'returns false for position (implementation pending)' do
          node[:position] = 'first'
          expect(renderer.evaluates?(item, node)).to be_falsey
        end

        describe 'for is-numeric conditions' do
          before { node[:'is-numeric'] = 'note archive' }

          it 'returns false unless all variables are numeric' do
            expect(renderer.evaluates?(item, node)).to be_falsey

            item.data[:archive] = 1
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.data[:note] = 'L2d'
            expect(renderer.evaluates?(item, node)).to be_truthy

            item.data[:archive] = 'second'
            expect(renderer.evaluates?(item, node)).to be_falsey
          end
        end

        describe 'for is-uncertain-date conditions' do
          before { node[:'is-uncertain-date'] = 'issued' }

          it 'returns false unless all variables contain uncertain dates' do
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.data[:issued] = 2012
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.data[:issued].uncertain!
            expect(renderer.evaluates?(item, node)).to be_truthy
          end
        end

        describe 'for locator conditions' do
          before { node[:locator] = 'figure book sub-verbo' }

          it 'returns false unless the locator matches all of the given locators' do
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.locator = :book
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.locator = 'volume'
            expect(renderer.evaluates?(item, node)).to be_falsey

            item.locator = 'figure'
            expect(renderer.evaluates?(item, node)).to be_falsey
          end

          describe 'when the match attribute is set to "any"' do
            before { node[:match] = 'any' }

            it 'returns false unless the locator matches any of the given locators' do
              expect(renderer.evaluates?(item, node)).to be_falsey
              
              item.locator = :book
              expect(renderer.evaluates?(item, node)).to be_truthy
              
              item.locator = 'volume'
              expect(renderer.evaluates?(item, node)).to be_falsey

              item.locator = 'figure'
              expect(renderer.evaluates?(item, node)).to be_truthy
            end

            it 'matches "sub verbo" as "sub-verbo"' do
              item.locator = 'sub-verbo'
              expect(renderer.evaluates?(item, node)).to be_truthy

              item.locator = 'sub verbo'
              expect(renderer.evaluates?(item, node)).to be_truthy
            end
          end
        end

        describe 'for type conditions' do
          before { node[:type] = 'book treaty' }

          it 'returns false unless the type matches all of the given types' do
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.data[:type] = :book
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.data[:type] = 'article'
            expect(renderer.evaluates?(item, node)).to be_falsey

            item.data[:type] = 'treaty'
            expect(renderer.evaluates?(item, node)).to be_falsey
          end

          describe 'when the match attribute is set to "any"' do
            before { node[:match] = 'any' }

            it 'returns false unless the locator matches any of the given locators' do
              expect(renderer.evaluates?(item, node)).to be_falsey
              
              item.data[:type] = :book
              expect(renderer.evaluates?(item, node)).to be_truthy
              
              item.data[:type] = 'article'
              expect(renderer.evaluates?(item, node)).to be_falsey

              item.data[:type] = 'treaty'
              expect(renderer.evaluates?(item, node)).to be_truthy
            end
          end
        end

        describe 'for variable conditions' do
          before { node[:variable] = 'volume issue' }
          
          it 'returns false unless the item has all variables' do
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.data[:volume] = 1
            expect(renderer.evaluates?(item, node)).to be_falsey
            
            item.data[:issue] = 1
            expect(renderer.evaluates?(item, node)).to be_truthy

            item.data[:volume] = nil
            expect(renderer.evaluates?(item, node)).to be_falsey
          end

          describe 'with internal negations' do
            before { node[:variable] = 'volume not:issue' }
            
            it 'returns false unless the item has (or does not have) all variables' do
              expect(renderer.evaluates?(item, node)).to be_falsey

              item.data[:volume] = 1
              expect(renderer.evaluates?(item, node)).to be_truthy

              item.data[:issue] = 1
              expect(renderer.evaluates?(item, node)).to be_falsey

              item.data[:volume] = nil
              expect(renderer.evaluates?(item, node)).to be_falsey
            end
          end

          describe 'and the any-matcher' do
            before { node[:match] = 'any' }

            it 'returns false unless the item has any of the variables' do
              expect(renderer.evaluates?(item, node)).to be_falsey

              item.data[:volume] = 1
              expect(renderer.evaluates?(item, node)).to be_truthy

              item.data[:issue] = 1
              expect(renderer.evaluates?(item, node)).to be_truthy
              
              item.data[:volume] = nil
              expect(renderer.evaluates?(item, node)).to be_truthy
            end
            
            describe 'with internal negations' do
              before { node[:variable] = 'volume not:issue' }

              it 'returns false unless the item has (or does not have) any of the variables' do
                expect(renderer.evaluates?(item, node)).to be_truthy

                item.data[:volume] = 1
                expect(renderer.evaluates?(item, node)).to be_truthy

                item.data[:issue] = 1
                expect(renderer.evaluates?(item, node)).to be_truthy

                item.data[:volume] = nil
                expect(renderer.evaluates?(item, node)).to be_falsey
              end
            end
          end
          
          describe 'and the none-matcher' do
            before { node[:match] = 'none' }

            it 'returns false unless the item has none of the variables' do
              expect(renderer.evaluates?(item, node)).to be_truthy

              item.data[:volume] = 1
              expect(renderer.evaluates?(item, node)).to be_falsey

              item.data[:issue] = 1
              expect(renderer.evaluates?(item, node)).to be_falsey
              
              item.data[:volume] = nil
              expect(renderer.evaluates?(item, node)).to be_falsey
            end
            
            describe 'with internal negations' do
              before { node[:variable] = 'volume not:issue' }

              it 'returns false unless the item has (or does not have) none of the variables' do
                expect(renderer.evaluates?(item, node)).to be_falsey

                item.data[:volume] = 1
                expect(renderer.evaluates?(item, node)).to be_falsey

                item.data[:issue] = 1
                expect(renderer.evaluates?(item, node)).to be_falsey

                item.data[:volume] = nil
                expect(renderer.evaluates?(item, node)).to be_truthy
              end
            end
          end
        end
      end

    end
  end
end
