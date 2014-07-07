require 'spec_helper'

module CiteProc
  module Ruby
    describe 'Renderer#render_group' do
      let(:renderer) { Renderer.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }

      let(:node) { CSL::Style::Group.new }

      it 'returns an empty string by default' do
        expect(renderer.render(item, node)).to eq('')

        node[:prefix] = '!'
        expect(renderer.render(item, node)).to eq('')
      end

      describe 'when there is a text node in the group' do
        before(:each) { node << CSL::Style::Text.new( :term => 'retrieved') }

        it 'returns the content of the nested node' do
          expect(renderer.render_group(item, node)).to eq('retrieved')
        end

        it 'applies formatting options to the nested node' do
          node[:'text-case'] = 'uppercase'
          expect(renderer.render(item, node)).to eq('RETRIEVED')
        end

        describe 'when there is a second text node in the group' do
          before(:each) { node << CSL::Style::Text.new( :term => 'from') }

          it 'returns the content of both nested nodes' do
            expect(renderer.render_group(item, node)).to eq('retrievedfrom')
          end

          describe 'when there is a delimter set on the group node' do
            before(:each) { node[:delimiter] = ' ' }

            it 'applies the delimiter to the output' do
              expect(renderer.render_group(item, node)).to eq('retrieved from')
            end

            it 'applies formatting options to the nested nodes only' do
              node[:'text-case'] = 'uppercase'
              node[:delimiter] = ' foo '
              node[:prefix] = '('
              node[:suffix] = ')'
              expect(renderer.render(item, node)).to eq('(RETRIEVED FOO FROM)')
            end

            describe 'when a nested node produces no output' do
              before(:each) do
                node << CSL::Style::Text.new( :term => 'fooo')
                node << CSL::Style::Text.new( :term => 'from')
              end

              it 'the delimiter does not apply to it' do
                expect(renderer.render_group(item, node)).to eq('retrieved from from')
              end
            end

            describe 'when there is a variable-based node in the group' do
              before(:each) { node << CSL::Style::Text.new( :variable => 'URL') }

              it 'returns the empty string when the variable is not present in the item' do
                expect(renderer.render_group(item, node)).to eq('')
              end

              describe 'when the variable is present' do
                before(:each) { item.data[:URL] = 'http://example.org' };

                it 'returns all nested renditions' do
                  expect(renderer.render_group(item, node)).to eq('retrieved from http://example.org')
                end
              end
            end
          end
        end
      end
    end
  end
end
