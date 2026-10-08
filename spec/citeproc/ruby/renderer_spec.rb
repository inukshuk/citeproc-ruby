# -*- encoding: utf-8 -*-

require 'spec_helper'

module CiteProc
  module Ruby

    describe Renderer do
      let(:renderer) { Renderer.new }

      describe 'title case and the item language' do
        let(:layout) do
          CSL::Style::Layout.new do |l|
            l << CSL::Style::Text.new(:variable => 'title', :'text-case' => 'title')
          end
        end

        let(:citation) { CSL::Style::Citation.new.tap { |c| c << layout } }

        def item(language)
          i = CiteProc::CitationItem.new(:id => language.to_s)
          i.data = CiteProc::Item.new(:id => language.to_s, :title => 'of mice and men', :language => language)
          i
        end

        it 'title cases items in English or without a language' do
          expect(renderer.render_citation([item('en')], citation)).to eq('Of Mice and Men')
          expect(renderer.render_citation([item(nil)], citation)).to eq('Of Mice and Men')
        end

        it 'does not title case items in other languages' do
          expect(renderer.render_citation([item('de')], citation)).to eq('of mice and men')
        end

        it 'uses the language of each cite' do
          layout[:delimiter] = '; '
          expect(renderer.render_citation([item('de'), item('en')], citation)).to eq('of mice and men; Of Mice and Men')
        end

        it 'clears the language after rendering' do
          renderer.render_citation([item('de')], citation)
          expect(renderer.state.language).to be_nil
        end
      end

      describe 'in-style locales' do
        def style(term)
          CSL::Style.parse(<<~XML)
            <style xmlns="http://purl.org/net/xbiblio/csl" version="1.0">
              <locale xml:lang="en">
                <terms><term name="editor">#{term}</term></terms>
              </locale>
              <citation>
                <layout>
                  <names variable="editor"><name/><label prefix=" (" suffix=")"/></names>
                </layout>
              </citation>
            </style>
          XML
        end

        let(:item) do
          i = CiteProc::CitationItem.new(:id => 'doe')
          i.data = CiteProc::Item.new(:id => 'doe', :type => 'book', :editor => [{ :family => 'Doe', :given => 'John' }])
          i
        end

        it 'are applied when rendering' do
          expect(renderer.render([item], style('EDITOR').citation)).to eq('John Doe (EDITOR)')
        end

        it 'of the current style are applied' do
          expect(renderer.render([item], style('ONE').citation)).to eq('John Doe (ONE)')
          expect(renderer.render([item], style('TWO').citation)).to eq('John Doe (TWO)')
        end

        it 'are updated after clearing the cache' do
          s = style('ONE')
          expect(renderer.render([item], s.citation)).to eq('John Doe (ONE)')

          s.locales[0].store 'editor', 'TWO'
          renderer.clear_cache!

          expect(renderer.render([item], s.citation)).to eq('John Doe (TWO)')
        end

        it 'do not change the locale' do
          locale = CSL::Locale.load('en-US')
          renderer.locale = locale
          renderer.render([item], style('EDITOR').citation)

          expect(renderer.locale).to equal(locale)
          expect(locale.translate('editor')).to eq('editor')
        end
      end

      describe 'style options' do
        let(:item) do
          i = CiteProc::CitationItem.new(:id => 'chen')
          i.data = CiteProc::Item.new(:id => 'chen', :author => [{ :family => 'Chen', :given => 'Hsien-Li' }])
          i
        end

        it 'drops hyphens from initials if initialize-with-hyphen is false' do
          style = CSL::Style.parse(<<~XML)
            <style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" initialize-with-hyphen="false">
              <citation>
                <layout>
                  <names variable="author"><name initialize-with="." form="long"/></names>
                </layout>
              </citation>
            </style>
          XML

          expect(renderer.render([item], style.citation)).to eq('H.L. Chen')
        end

        it 'formats page locators using the page-range-format' do
          style = CSL::Style.parse(<<~XML)
            <style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" page-range-format="expanded">
              <citation>
                <layout>
                  <text variable="locator"/>
                </layout>
              </citation>
            </style>
          XML

          item.locator = '427-30'
          expect(renderer.render([item], style.citation)).to eq('427–430')

          item.label = 'chapter'
          expect(renderer.render([item], style.citation)).to eq('427–30')
        end
      end

      describe '#locator_abbreviations' do
        it 'includes the localized short terms of locator labels' do
          renderer.locale = 'de-DE'
          expect(renderer.locator_abbreviations).to include('S.' => 'page', 'Bd.' => 'volume', 'vol.' => 'volume')
        end
      end

      describe 'second-field-align' do
        let(:item) do
          i = CiteProc::CitationItem.new(:id => 'doe')
          i.data = CiteProc::Item.new(:id => 'doe', :title => 'Title')
          i
        end

        def style(align)
          CSL::Style.parse(<<~XML)
            <style xmlns="http://purl.org/net/xbiblio/csl" version="1.0">
              <bibliography#{align}>
                <layout suffix=".">
                  <text value="1" suffix=". "/>
                  <text variable="title"/>
                </layout>
              </bibliography>
            </style>
          XML
        end

        it 'renders the first field in the left margin and the rest inline' do
          renderer.format = 'html'
          expect(renderer.render_bibliography(item, style(' second-field-align="flush"').bibliography)).to eq(
            '<div class="csl-left-margin">1. </div><div class="csl-right-inline">Title.</div>')
        end

        it 'removes trailing whitespace from the inline fields' do
          renderer.format = 'html'
          style = style(' second-field-align="flush"')
          style.bibliography.layout.each_child.to_a.last[:suffix] = '. '

          expect(renderer.render_bibliography(item, style.bibliography)).to eq(
            '<div class="csl-left-margin">1. </div><div class="csl-right-inline">Title.</div>')
        end

        it 'renders all fields together by default' do
          renderer.format = 'html'
          expect(renderer.render_bibliography(item, style('').bibliography)).to eq('1. Title.')
        end
      end

      describe '#locale=' do
        it 'loads the locale' do
          renderer.locale = 'de-DE'
          expect(renderer.locale.to_s).to eq('de-DE')
        end

        it 'uses locale instances as is' do
          locale = CSL::Locale.load('de-DE')
          renderer.locale = locale
          expect(renderer.locale).to equal(locale)
        end

        it 'falls back to the language for unknown regions' do
          renderer.locale = 'de-XX'
          expect(renderer.locale.to_s).to eq('de-DE')
        end

        it 'falls back to the default locale for unknown languages' do
          renderer.locale = 'xx'
          expect(renderer.locale.to_s).to eq('en-US')
        end
      end

      describe '#format_page_range' do
        it 'uses the localized page range delimiter' do
          allow(renderer).to receive(:translate).with('page-range-delimiter').and_return('—')
          expect(renderer.format_page_range('42-5', 'expanded')).to eq('42—45')
        end
      end

    end

  end
end
