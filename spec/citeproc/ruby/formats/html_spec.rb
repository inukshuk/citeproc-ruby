require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Formats::Html' do
      it 'can be created with an options hash' do
        expect(Formats::Html.new(:css_only => true)).to be_css_only
      end
    end

    describe 'Formats::Html#apply' do
      let(:format) { Format.load 'html' }
      let(:node) { CSL::Style::Text.new }

      describe 'text-case formats' do
        it 'supports lowercase' do
          node[:'text-case'] = 'lowercase'
          expect(format.apply('Foo BAR', node)).to eq('foo bar')
        end
      end

      describe 'entity escaping' do
        it 'escapes entities in the original text' do
          node[:'text-case'] = 'lowercase'
          expect(format.apply('Foo & BAR', node)).to eq('foo &amp; bar')
        end

        it 'does not not apply casing to escaped entities' do
          node[:'text-case'] = 'uppercase'
          expect(format.apply('Foo & BAR', node)).to eq('FOO &amp; BAR')
        end

        it 'escapes entities in affixes' do
          node[:prefix] = '<'
          node[:suffix] = '>'
          expect(format.apply('foo', node)).to eq('&lt;foo&gt;')
        end

        it 'escapes entities in quotes' do
          locale = CSL::Locale.new
          locale.store 'open-quote', '<'
          locale.store 'close-quote', '>'

          node[:quotes] = true
          expect(format.apply('foo', node, locale)).to eq('&lt;foo&gt;')
        end
      end

      describe 'affixes' do
        it 'are added after text formats have been applied' do
          node[:prefix] = 'foo'
          node[:suffix] = 'ooo'
          node[:'font-style'] = 'italic'

          expect(format.apply('ooo', node)).to eq('foo<i>ooo</i>ooo')
        end

        it 'are added before text formats have been applied for layout nodes' do
          layout = CSL::Style::Layout.new

          layout[:prefix] = 'foo'
          layout[:suffix] = 'ooo'
          layout[:'font-style'] = 'italic'

          expect(format.apply('ooo', layout)).to eq('<i>foooooooo</i>')
        end
      end

      describe 'font-style' do
        it 'supports italic in both modes' do
          node[:'font-style'] = 'italic'

          expect(format.apply('foo bar', node)).to eq('<i>foo bar</i>')

          format.config[:italic] = 'em'
          expect(format.apply('foo bar', node)).to eq('<em>foo bar</em>')

          format.config[:css_only] = true
          expect(format.apply('foo bar', node)).to eq('<span style="font-style: italic">foo bar</span>')
        end

        it 'supports normal and oblique via css' do
          node[:'font-style'] = 'oblique'
          expect(format.apply('foo bar', node)).to eq('<span style="font-style: oblique">foo bar</span>')

          node[:'font-style'] = 'normal'
          expect(format.apply('foo bar', node)).to eq('<span style="font-style: normal">foo bar</span>')
        end
      end

      it 'supports font-variant via css' do
        node[:'font-variant'] = 'small-caps'
        expect(format.apply('foo bar', node)).to eq('<span style="font-variant: small-caps">foo bar</span>')
      end

      describe 'font-weight' do
        it 'supports bold in both modes' do
          node[:'font-weight'] = 'bold'

          expect(format.apply('foo bar', node)).to eq('<b>foo bar</b>')

          format.config[:bold] = 'strong'
          expect(format.apply('foo bar', node)).to eq('<strong>foo bar</strong>')

          format.config[:css_only] = true
          expect(format.apply('foo bar', node)).to eq('<span style="font-weight: bold">foo bar</span>')
        end

        it 'supports normal and light via css' do
          node[:'font-weight'] = 'light'
          expect(format.apply('foo bar', node)).to eq('<span style="font-weight: light">foo bar</span>')

          node[:'font-weight'] = 'normal'
          expect(format.apply('foo bar', node)).to eq('<span style="font-weight: normal">foo bar</span>')
        end
      end

      it 'supports text-decoration via css' do
        node[:'text-decoration'] = 'underline'
        expect(format.apply('foo bar', node)).to eq('<span style="text-decoration: underline">foo bar</span>')
      end

      it 'supports vertical-align via css' do
        node[:'vertical-align'] = 'sup'
        expect(format.apply('foo bar', node)).to eq('<span style="vertical-align: super">foo bar</span>')
      end

      describe 'display' do
        it 'is supported in an outer container' do
          node[:'display'] = 'block'
          node[:'text-decoration'] = 'underline'
          expect(format.apply('foo bar', node)).to eq('<div class="csl-block"><span style="text-decoration: underline">foo bar</span></div>')

          node[:prefix] = '('
          expect(format.apply('foo bar', node)).to eq('<div class="csl-block">(<span style="text-decoration: underline">foo bar</span></div>')
        end
      end

      describe 'bibliography formats' do
        let(:bibliography) do
          CiteProc::Bibliography.new do |b|
            b.push 'id-1', 'foo'
            b.push 'id-2', 'bar'
          end
        end

        it 'can be applied' do
          format.config[:bib_indent] = nil
          format.bibliography(bibliography)
          expect(bibliography.join).to eq('<ol class="csl-bibliography"><li class="csl-entry">foo</li><li class="csl-entry">bar</li></ol>')
        end

        it 'can be customized' do
          format.config[:bib_indent] = nil
          format.config[:bib_entry_class] = nil
          format.config[:bib_entry] = 'span'
          format.config[:bib_container] = 'div'

          format.bibliography(bibliography)
          expect(bibliography.join).to eq('<div class="csl-bibliography"><span>foo</span><span>bar</span></div>')
        end
      end
    end

  end
end
