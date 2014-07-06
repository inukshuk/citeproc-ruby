# -*- encoding: utf-8 -*-

require 'spec_helper'

module CiteProc
  module Ruby

    describe Renderer do
      let(:renderer) { Renderer.new }

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

        it 'formats multiple page ranges' do
          expect(renderer.format_page_range('42-45 and 57; 81-3 & 123-4', 'minimal-two')).to eq('42–45 and 57; 81–83 & 123–24')
        end
      end
    end

  end
end
