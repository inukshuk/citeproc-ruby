require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Formats::Html#apply' do
      let(:format) { Format.load 'html' }
      let(:node) { CSL::Style::Text.new }

      describe 'text-case formats' do
        it 'supports lowercase' do
          node[:'text-case'] = 'lowercase'
          format.apply('Foo BAR', node).should == 'foo bar'
        end
      end

      describe 'font-style' do
        it 'supports italic in both modes' do
          node[:'font-style'] = 'italic'

          format.apply('foo bar', node).should == '<i>foo bar</i>'

          format.config[:italic] = 'em'
          format.apply('foo bar', node).should == '<em>foo bar</em>'

          format.config[:css_only] = true
          format.apply('foo bar', node).should == '<span style="font-style: italic">foo bar</span>'
        end

        it 'supports normal and oblique via css' do
          node[:'font-style'] = 'oblique'
          format.apply('foo bar', node).should == '<span style="font-style: oblique">foo bar</span>'

          node[:'font-style'] = 'normal'
          format.apply('foo bar', node).should == '<span style="font-style: normal">foo bar</span>'
        end
      end

      it 'supports font-variant via css' do
        node[:'font-variant'] = 'small-caps'
        format.apply('foo bar', node).should == '<span style="font-variant: small-caps">foo bar</span>'
      end

      describe 'font-weight' do
        it 'supports bold in both modes' do
          node[:'font-weight'] = 'bold'

          format.apply('foo bar', node).should == '<b>foo bar</b>'

          format.config[:bold] = 'strong'
          format.apply('foo bar', node).should == '<strong>foo bar</strong>'

          format.config[:css_only] = true
          format.apply('foo bar', node).should == '<span style="font-weight: bold">foo bar</span>'
        end

        it 'supports normal and light via css' do
          node[:'font-weight'] = 'light'
          format.apply('foo bar', node).should == '<span style="font-weight: light">foo bar</span>'

          node[:'font-weight'] = 'normal'
          format.apply('foo bar', node).should == '<span style="font-weight: normal">foo bar</span>'
        end
      end

      it 'supports text-decoration via css' do
        node[:'text-decoration'] = 'underline'
        format.apply('foo bar', node).should == '<span style="text-decoration: underline">foo bar</span>'
      end

      it 'supports vertical-align via css' do
        node[:'vertical-align'] = 'sup'
        format.apply('foo bar', node).should == '<span style="vertical-align: sup">foo bar</span>'
      end

      describe 'display' do
        it 'is supported in an outer container' do
          node[:'display'] = 'block'
          node[:'text-decoration'] = 'underline'
          format.apply('foo bar', node).should == '<div style="display: block"><span style="text-decoration: underline">foo bar</span></div>'

          node[:prefix] = '('
          format.apply('foo bar', node).should == '<div style="display: block">(<span style="text-decoration: underline">foo bar</span></div>'
        end
      end
    end

  end
end
