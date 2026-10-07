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
        it 'supports "minimal" format' do
          expect(renderer.format_page_range('42-45', 'minimal')).to eq('42–5')
          expect(renderer.format_page_range('321-328', 'minimal')).to eq('321–8')
          expect(renderer.format_page_range('2787-2816', 'minimal')).to eq('2787–816')
          expect(renderer.format_page_range('8-45', 'minimal')).to eq('8–45')

          expect(renderer.format_page_range('42-5', 'minimal')).to eq('42–5')
          expect(renderer.format_page_range('321-28', 'minimal')).to eq('321–8')
          expect(renderer.format_page_range('321-8', 'minimal')).to eq('321–8')
          expect(renderer.format_page_range('2787-816', 'minimal')).to eq('2787–816')
        end

        it 'supports "minimal-two" format' do
          expect(renderer.format_page_range('42-45', 'minimal-two')).to eq('42–45')
          expect(renderer.format_page_range('321-328', 'minimal-two')).to eq('321–28')
          expect(renderer.format_page_range('2787-2816', 'minimal-two')).to eq('2787–816')
          expect(renderer.format_page_range('2-5', 'minimal-two')).to eq('2–5')
          expect(renderer.format_page_range('2-402', 'minimal-two')).to eq('2–402')

          expect(renderer.format_page_range('42-5', 'minimal-two')).to eq('42–45')
          expect(renderer.format_page_range('321-28', 'minimal-two')).to eq('321–28')
          expect(renderer.format_page_range('321-8', 'minimal-two')).to eq('321–28')
          expect(renderer.format_page_range('2787-816', 'minimal-two')).to eq('2787–816')
        end

        it 'supports "expanded" format' do
          expect(renderer.format_page_range('42-45', 'expanded')).to eq('42–45')
          expect(renderer.format_page_range('321-328', 'expanded')).to eq('321–328')
          expect(renderer.format_page_range('2787-2816', 'expanded')).to eq('2787–2816')
          expect(renderer.format_page_range('2-5', 'expanded')).to eq('2–5')
          expect(renderer.format_page_range('2-402', 'expanded')).to eq('2–402')

          expect(renderer.format_page_range('42-5', 'expanded')).to eq('42–45')
          expect(renderer.format_page_range('321 - 28', 'expanded')).to eq('321–328')
          expect(renderer.format_page_range('321 -8', 'expanded')).to eq('321–328')
          expect(renderer.format_page_range('2787- 816', 'expanded')).to eq('2787–2816')
        end

        it 'supports "chicago" format' do
          expect(renderer.format_page_range('3-10; 71-72', 'chicago')).to eq('3–10; 71–72')
          expect(renderer.format_page_range('100-104; 600-613; 1100-23', 'chicago')).to eq('100–104; 600–613; 1100–1123')
          expect(renderer.format_page_range('107-08; 505-517; 1002-006', 'chicago')).to eq('107–8; 505–17; 1002–6')
          expect(renderer.format_page_range('321-325; 415-532; 11564-11568; 13792-803', 'chicago')).to eq('321–25; 415–532; 11564–68; 13792–803')
          expect(renderer.format_page_range('1496-504; 2787-2816', 'chicago')).to eq('1496–1504; 2787–2816')
        end

        it 'supports "chicago-16" format' do
          expect(renderer.format_page_range('1496-1500; 1087-89; 11564-11615', 'chicago-16')).to eq('1496–500; 1087–89; 11564–615')
          expect(renderer.format_page_range('1100-13; 101-108; 321-8', 'chicago-16')).to eq('1100–1113; 101–8; 321–28')
        end

        it 'formats multiple page ranges' do
          expect(renderer.format_page_range('42-45 and 57; 81-3 & 123-4', 'minimal-two')).to eq('42–45 and 57; 81–83 & 123–24')
        end

        it 'formats page ranges with the same prefix' do
          expect(renderer.format_page_range('N110 - N5', 'expanded')).to eq('N110–N115')
          expect(renderer.format_page_range('n11564-n1568', 'chicago')).to eq('n11564–68')
          expect(renderer.format_page_range('8n11564-8n1568', 'minimal')).to eq('8n11564–8')
        end

        it 'does not format page ranges with different prefixes' do
          expect(renderer.format_page_range('N110 - 5', 'expanded')).to eq('N110-5')
          expect(renderer.format_page_range('n11564-1568', 'minimal')).to eq('n11564-1568')
          expect(renderer.format_page_range('123N110 - N5, 456K200 - 99', 'expanded')).to eq('123N110-N5, 456K200-99')
        end

        it 'uses the range delimiter for roman numerals' do
          expect(renderer.format_page_range('xxv-xxviii', 'chicago-16')).to eq('xxv–xxviii')
          expect(renderer.format_page_range('i-ix', nil)).to eq('i–ix')
        end

        it 'does not format words or escaped hyphens' do
          expect(renderer.format_page_range('Michaelson-Morely', nil)).to eq('Michaelson-Morely')
          expect(renderer.format_page_range('327\\-30', 'expanded')).to eq('327-30')
        end
      end
    end

  end
end
