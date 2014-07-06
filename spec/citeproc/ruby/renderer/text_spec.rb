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
          expect(renderer.render_text(item, node)).to eq('')
        end

        it 'returns an empty string for an item with variables' do
          item.data.title = 'foo'
          expect(renderer.render_text(item, node)).to eq('')
        end
      end

      describe 'given a text node with a value' do
        let(:node) { CSL::Style::Text.new(:value => 'foobar') }

        it 'returns the value for an empty item' do
          expect(renderer.render_text(item, node)).to eq('foobar')
        end

        it 'returns the value for an item with variables' do
          item.data.title = 'foo'
          expect(renderer.render_text(item, node)).to eq('foobar')
        end
      end

      describe 'given a text node with a variable' do
        let(:node) { CSL::Style::Text.new(:variable => 'title') }

        it 'returns an empty strong for an empty item' do
          expect(renderer.render_text(item, node)).to eq('')
        end

        it 'returns an empty strong for an item with no matching variable' do
          item.data.publisher = 'the full title'
          expect(renderer.render_text(item, node)).to eq('')
        end

        it "returns the variable's value for an item with a matching variable" do
          item.data.title = 'the full title'
          expect(renderer.render_text(item, node)).to eq('the full title')
        end

        describe 'when the form attribute is set to :short' do
          before(:each) {
            item.data.title = 'the full title'
            node[:form] = 'short'
          }

          it "prefers the short version if available" do
            item.data.title_short = 'the short title'
            expect(renderer.render_text(item, node)).to eq('the short title')
          end

          it "falls back to the variable if unavailable" do
            expect(renderer.render_text(item, node)).to eq('the full title')
          end

          it "falls back to the long form if the short form variable is not present" do
            node[:variable] = 'title-short'
            expect(renderer.render_text(item, node)).to eq('the full title')
          end
        end
      end

      describe 'given a text node with a variable' do
        let(:node) { CSL::Style::Text.new(:term => 'anonymous') }

        it "returns the term's long form by default" do
          expect(renderer.render_text(item, node)).to eq('anonymous')
        end

        describe 'when the form attribute is set to :short' do
          before(:each) { node[:form] = 'short' }

          it "returns the term's short form by default" do
            expect(renderer.render_text(item, node)).to eq('anon.')
          end

          it 'falls back to the long version if there is no short version' do
            node[:term] = 'et-al'
            expect(renderer.render_text(item, node)).to eq('et al.')
          end
        end
      end

      describe 'given a text node with a macro reference' do
        let(:node) { CSL::Style::Text.new(:macro => 'foo') }

        let(:macro) do
          CSL::Style::Macro.new(:name => 'foo') do |m|
            m << CSL::Style::Text.new(:value => 'foobar')
          end
        end

        it 'renders the macro' do
          allow(node).to receive(:macro).and_return(macro)
          expect(renderer.render(item, node)).to eq('foobar')
        end

        it 'applies formats to the result' do
          allow(node).to receive(:macro).and_return(macro)
          node[:prefix] = '('
          node[:suffix] = ')'
          expect(renderer.render(item, node)).to eq('(foobar)')
        end
      end
    end

  end
end
