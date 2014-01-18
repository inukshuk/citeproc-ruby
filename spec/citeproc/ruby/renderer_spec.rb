# -*- encoding: utf-8 -*-

require 'spec_helper'

module CiteProc
  module Ruby

    describe Renderer do
      let(:renderer) { Renderer.new }

      describe '#format_page_range' do
        it 'supports "minimal" format' do
          renderer.format_page_range('42-45', 'minimal').should == '42–5'
          renderer.format_page_range('321-328', 'minimal').should == '321–8'
          renderer.format_page_range('2787-2816', 'minimal').should == '2787–816'
          renderer.format_page_range('8-45', 'minimal').should == '8–45'

          renderer.format_page_range('42-5', 'minimal').should == '42–5'
          renderer.format_page_range('321-28', 'minimal').should == '321–8'
          renderer.format_page_range('321-8', 'minimal').should == '321–8'
          renderer.format_page_range('2787-816', 'minimal').should == '2787–816'
        end

        it 'supports "minimal-two" format' do
          renderer.format_page_range('42-45', 'minimal-two').should == '42–45'
          renderer.format_page_range('321-328', 'minimal-two').should == '321–28'
          renderer.format_page_range('2787-2816', 'minimal-two').should == '2787–816'
          renderer.format_page_range('2-5', 'minimal-two').should == '2–5'
          renderer.format_page_range('2-402', 'minimal-two').should == '2–402'

          renderer.format_page_range('42-5', 'minimal-two').should == '42–45'
          renderer.format_page_range('321-28', 'minimal-two').should == '321–28'
          renderer.format_page_range('321-8', 'minimal-two').should == '321–28'
          renderer.format_page_range('2787-816', 'minimal-two').should == '2787–816'
        end

        it 'supports "expanded" format' do
          renderer.format_page_range('42-45', 'expanded').should == '42–45'
          renderer.format_page_range('321-328', 'expanded').should == '321–328'
          renderer.format_page_range('2787-2816', 'expanded').should == '2787–2816'
          renderer.format_page_range('2-5', 'expanded').should == '2–5'
          renderer.format_page_range('2-402', 'expanded').should == '2–402'

          renderer.format_page_range('42-5', 'expanded').should == '42–45'
          renderer.format_page_range('321 - 28', 'expanded').should == '321–328'
          renderer.format_page_range('321 -8', 'expanded').should == '321–328'
          renderer.format_page_range('2787- 816', 'expanded').should == '2787–2816'
        end

        it 'supports "chicago" format' do
          renderer.format_page_range('3-10; 71-72', 'chicago').should == '3–10; 71–72'
          renderer.format_page_range('100-104; 600-613; 1100-23', 'chicago').should == '100–104; 600–613; 1100–1123'
          renderer.format_page_range('107-08; 505-517; 1002-006', 'chicago').should == '107–8; 505–17; 1002–6'
          renderer.format_page_range('321-325; 415-532; 11564-11568; 13792-803', 'chicago').should == '321–25; 415–532; 11564–68; 13792–803'
          renderer.format_page_range('1496-504; 2787-2816', 'chicago').should == '1496–1504; 2787–2816'
        end

        it 'formats multiple page ranges' do
          renderer.format_page_range('42-45 and 57; 81-3 & 123-4', 'minimal-two').should == '42–45 and 57; 81–83 & 123–24'
        end
      end
    end

  end
end
