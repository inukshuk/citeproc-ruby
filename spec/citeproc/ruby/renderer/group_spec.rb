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
        renderer.render(item, node).should == ''

        node[:prefix] = '!'
        renderer.render(item, node).should == ''
      end

      describe 'when there is a text node in the group' do
        before(:each) { node << CSL::Style::Text.new( :term => 'retrieved') }

        it 'returns the content of the nested node' do
          renderer.render_group(item, node).should == 'retrieved'
        end

        it 'applies formatting options to the nested node' do
          node[:'text-case'] = 'uppercase'
          renderer.render(item, node).should == 'RETRIEVED'
        end

        describe 'when there is a second text node in the group' do
          before(:each) { node << CSL::Style::Text.new( :term => 'from') }

          it 'returns the content of both nested nodes' do
            renderer.render_group(item, node).should == 'retrievedfrom'
          end

          describe 'when there is a delimter set on the group node' do
            before(:each) { node[:delimiter] = ' ' }

            it 'applies the delimiter to the output' do
              renderer.render_group(item, node).should == 'retrieved from'
            end

            it 'applies formatting options to the nested nodes only' do
              node[:'text-case'] = 'uppercase'
              node[:delimiter] = ' foo '
              node[:prefix] = '('
              node[:suffix] = ')'
              renderer.render(item, node).should == '(RETRIEVED foo FROM)'
            end

            describe 'when a nested node produces no output' do
              before(:each) do
                node << CSL::Style::Text.new( :term => 'fooo')
                node << CSL::Style::Text.new( :term => 'from')
              end

              it 'the delimiter does not apply to it' do
                renderer.render_group(item, node).should == 'retrieved from from'
              end
            end

            describe 'when there is a variable-based node in the group' do
              before(:each) { node << CSL::Style::Text.new( :variable => 'URL') }

              it 'returns the empty string when the variable is not present in the item' do
                renderer.render_group(item, node).should == ''
              end

              describe 'when the variable is present' do
                before(:each) { item.data[:URL] = 'http://example.org' };

                it 'returns all nested renditions' do
                  renderer.render_group(item, node).should == 'retrieved from http://example.org'
                end
              end
            end
          end
        end
      end
    end
  end
end
