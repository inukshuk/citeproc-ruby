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

      describe 'when there is a names node with substitute in the group' do

        before(:each) do
          subst = CSL::Style::Substitute.new()
          subst << CSL::Style::Text.new( :value => 'Anonymous') 
          names = CSL::Style::Names.new( :variable => 'author')
          names << subst
          node << names
        end

        describe 'when the variable is set' do
          before(:each) { item.data.author = 'Some Author' }

          it 'returns the content of the nested node' do
            expect(renderer.render_group(item, node)).to eq('Some Author')
          end
        end

        describe 'when the variable is not set' do
          it 'returns the substitution of the nested node' do
            expect(renderer.render_group(item, node)).to eq('Anonymous')
          end
        end

      end

      describe 'when a macro or nested group in the group produces output' do
        let(:style) do
          CSL::Style.parse(<<~XML)
            <style xmlns="http://purl.org/net/xbiblio/csl" version="1.0">
              <macro name="date">
                <choose>
                  <if variable="issued"><date variable="issued"><date-part name="year"/></date></if>
                  <else><text term="no date" form="short"/></else>
                </choose>
              </macro>
              <citation>
                <layout>
                  <group delimiter="; ">
                    <text macro="date"/>
                    <text variable="volume"/>
                  </group>
                  <group delimiter="; ">
                    <group><text term="in"/></group>
                    <text variable="volume"/>
                  </group>
                </layout>
              </citation>
            </style>
          XML
        end

        let(:groups) { style.citation.layout.each_child.to_a }

        it 'treats a non-empty macro as a non-empty variable' do
          expect(renderer.render(item, groups[0])).to eq('n.d.')
        end

        it 'treats a non-empty nested group as a non-empty variable' do
          expect(renderer.render(item, groups[1])).to eq('in')
        end
      end

      describe 'when the group contains the year-suffix' do
        before do
          node << CSL::Style::Text.new(:term => 'no date', :form => 'short')
          node << CSL::Style::Text.new(:variable => 'year-suffix')
        end

        it 'does not count the year-suffix as a variable' do
          expect(renderer.render(item, node)).to eq('n.d.')
        end
      end

      describe 'when the date in the group renders no date parts' do
        before do
          item.data[:issued] = '1965'

          node << CSL::Style::Text.new(:value => 'and not this')
          node << CSL::Style::Date.new(:variable => 'issued') { |d| d << CSL::Style::DatePart.new(:name => 'month') }
        end

        it 'treats the date as an empty variable' do
          expect(renderer.render(item, node)).to eq('')
        end

        it 'treats the date as non-empty if it renders elsewhere in the group' do
          node.children.unshift CSL::Style::Date.new(:variable => 'issued') { |d| d << CSL::Style::DatePart.new(:name => 'year') }
          expect(renderer.render(item, node)).to eq('1965and not this')
        end
      end

      describe 'when the group contains a substituted variable' do
        let(:style) do
          CSL::Style.parse(<<~XML)
            <style xmlns="http://purl.org/net/xbiblio/csl" version="1.0">
              <citation>
                <layout>
                  <names variable="author">
                    <substitute><names variable="editor"/></substitute>
                  </names>
                  <group>
                    <text value="edited by "/>
                    <names variable="editor"/>
                  </group>
                </layout>
              </citation>
            </style>
          XML
        end

        before { item.data[:editor] = 'Doe, John' }

        it 'treats the substituted variable as empty' do
          names, group = style.citation.layout.each_child.to_a
          expect(renderer.render(item, names)).to eq('John Doe')
          expect(renderer.render(item, group)).to eq('')
        end
      end
    end
  end
end
