require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Renderer#render_date' do
      let(:renderer) { Renderer.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }

      describe 'localized rendering' do
        let(:node) { CSL::Style::Date.new(:variable => 'issued', :form => 'numeric') }

        describe 'given an item issued on January 27th, 2012' do
          before(:each) { item.data[:issued] = '2012-01-27' }

          it "uses the locale's date parts to render the date" do
            expect(renderer.render(item, node)).to eq('01/27/2012')
          end
        end

        it 'uses the delimiter of the localized date' do
          localized = CSL::Locale::Date.new(:form => 'text', :delimiter => ' ')
          localized << CSL::Locale::DatePart.new(:name => 'month')
          localized << CSL::Locale::DatePart.new(:name => 'year')
          allow(renderer.locale).to receive(:date).and_return([localized])

          item.data[:issued] = '2012-01-27'
          node[:form] = 'text'
          expect(renderer.render(item, node)).to eq('January 2012')
        end

        it 'renders date ranges' do
          item.data[:issued] = [[2005, 11, 15], [2006, 12, 20]]
          node[:'date-parts'] = 'year-month'
          expect(renderer.render(item, node)).to eq('11/2005–12/2006')
        end
      end

      describe 'range rendering' do
        let(:node) do
          CSL::Style::Date.new(:variable => 'issued').tap do |d|
            d << CSL::Style::DatePart.new(:name => 'day', :suffix => ' ')
            d << CSL::Style::DatePart.new(:name => 'month', :suffix => ' ')
            d << CSL::Style::DatePart.new(:name => 'year')
          end
        end

        it 'renders day ranges' do
          item.data[:issued] = [[2003, 8, 10], [2003, 8, 23]]
          expect(renderer.render(item, node)).to eq('10–23 August 2003')
        end

        it 'renders month ranges' do
          item.data[:issued] = [[2003, 8, 3], [2003, 10, 23]]
          expect(renderer.render(item, node)).to eq('3 August–23 October 2003')
        end

        it 'renders year ranges' do
          item.data[:issued] = [[1987, 8, 3], [2003, 10, 23]]
          expect(renderer.render(item, node)).to eq('3 August 1987–23 October 2003')
        end

        it 'renders open ranges' do
          item.data[:issued] = [[1987], [0]]
          expect(renderer.render(item, node)).to eq('1987–')
        end

        it 'renders dates of different precision in full' do
          item.data[:issued] = [[2003], [2003, 5]]
          expect(renderer.render(item, node)).to eq('2003–May 2003')
        end

        it 'renders identical dates once' do
          item.data[:issued] = [[2003, 8, 3], [2003, 8, 3]]
          expect(renderer.render(item, node)).to eq('3 August 2003')
        end

        it 'ignores differences in date parts that are not rendered' do
          node.parts.first.unlink
          item.data[:issued] = [[2003, 8, 3], [2003, 8, 23]]
          expect(renderer.render(item, node)).to eq('August 2003')
        end

        it 'uses the range delimiter of the largest differing date part' do
          node.parts[1][:'range-delimiter'] = ' to '
          item.data[:issued] = [[2003, 8, 3], [2003, 10, 23]]
          expect(renderer.render(item, node)).to eq('3 August to 23 October 2003')
        end

        it 'renders season ranges' do
          node.parts.first.unlink
          item.data[:issued] = [[1999, 21], [2001, 22]]
          expect(renderer.render(item, node)).to eq('Spring 1999–Summer 2001')
        end

        it 'skips date parts without values' do
          item.data[:issued] = [[1999, 22], [1999, 21]]
          expect(renderer.render(item, node)).to eq('Summer–Spring 1999')
        end
      end

      describe 'static rendering' do
        let(:node) { CSL::Style::Date.new(:variable => 'issued') }

        describe 'given an item issued on January 27th, 2012' do
          before(:each) { item.data[:issued] = '2012-01-27' }

          it 'returns an empty string by default' do
            expect(renderer.render_date(item, node)).to eq('')
          end

          describe 'and given a node with a year part' do
            before(:each) { node << CSL::Style::DatePart.new(:name => 'year') }

            it 'returns the year as "2012"' do
              expect(renderer.render_date(item, node)).to eq('2012')
            end

            describe 'and a day part' do
              before(:each) { node << CSL::Style::DatePart.new(:name => 'day') }

              it 'returns "201227"' do
                expect(renderer.render_date(item, node)).to eq('201227')
              end

              it 'applies delimiters when set on the node' do
                node[:delimiter] = '/'
                expect(renderer.render_date(item, node)).to eq('2012/27')
              end

              describe 'and a month part' do
                before(:each) { node << CSL::Style::DatePart.new(:name => 'month') }

                it 'returns "201227January"' do
                  expect(renderer.render_date(item, node)).to eq('201227January')
                end

                it 'returns "2012/27/01" when the month form set to "numeric-leading-zeros" and the node has a delimiter "/"' do
                  node.parts.last[:form] = 'numeric-leading-zeros'
                  node[:delimiter] = '/'
                  expect(renderer.render_date(item, node)).to eq('2012/27/01')
                end
              end
            end
          end
        end
      end

    end

    describe 'Renderer#render_date_part' do
      let(:renderer) { Renderer.new }
      let(:node) { CSL::Style::DatePart.new }

      let(:today) { CiteProc::Date.today }

      let(:january) { CiteProc::Date.new([2012, 1]) }
      let(:december) { CiteProc::Date.new([2012, 12]) }
      let(:independence) { CiteProc::Date.new([1776, 7, 4]) }

      it 'returns an empty string by default' do
        expect(renderer.render_date_part(CiteProc::Date.today, node)).to eq('')
      end

      describe 'when the name is set to "day"' do
        before(:each) { node[:name] = 'day' }

        it 'renders the day as number by default' do
          expect(renderer.render_date_part(today, node)).to eq(today.day.to_s)
        end

        it 'renders the day as an ordinal number when the form is set to "ordinal"' do
          node[:form] = 'ordinal'
          expect(renderer.render_date_part(independence, node)).to eq('4th')

          renderer.locale.limit_day_ordinals!
          expect(renderer.render_date_part(independence, node)).to eq('4')

          independence.day = 1
          expect(renderer.render_date_part(independence, node)).to eq('1st')
        end
      end

      describe 'when the name is set to "month"' do
        before(:each) { node[:name] = 'month' }

        it "renders the month's full name by default" do
          expect(renderer.render_date_part(january, node)).to eq('January')
          expect(renderer.render_date_part(december, node)).to eq('December')
        end

        it "renders the month's full name as the long form" do
          node[:form] = 'long'
          expect(renderer.render_date_part(january, node)).to eq('January')
        end

        it "renders the month's short name as the short form" do
          node[:form] = 'short'
          expect(renderer.render_date_part(january, node)).to eq('Jan.')
        end

        it 'renders the month as number as the numeric form' do
          node[:form] = 'numeric'
          expect(renderer.render_date_part(january, node)).to eq('1')
        end

        it 'renders the month as number with a leading zero when form is set to numeric-leading-zeros' do
          node[:form] = 'numeric-leading-zeros'
          expect(renderer.render_date_part(january, node)).to eq('01')
          expect(renderer.render_date_part(december, node)).to eq('12')
        end

        it 'renders the name of the season when a season is set' do
          date = CiteProc::Date.new([2012])
          date.season = 4
          expect(renderer.render_date_part(date, node)).to eq('Winter')
        end

        it 'renders the season field verbatim if it is no season' do
          date = CiteProc::Date.new([2012])
          date.season = 'Holiday'
          expect(renderer.render_date_part(date, node)).to eq('Holiday')
        end
      end

      describe 'when the name is set to "year"' do
        before(:each) { node[:name] = 'year' }

        it 'renders the full year by default' do
          expect(renderer.render_date_part(today, node)).to eq(today.year.to_s)
        end

        it 'renders the full year when form is set to long' do
          node[:form] = 'long'
          expect(renderer.render_date_part(january, node)).to eq('2012')
        end

        it 'renders the short year when form is set to short' do
          node[:form] = 'short'
          expect(renderer.render_date_part(january, node)).to eq('12')
        end

        it 'adds AD if applicable' do
          expect(renderer.render_date_part(CiteProc::Date.new([200]), node)).to eq('200AD')
        end

        it 'adds BC if applicable' do
          expect(renderer.render_date_part(CiteProc::Date.new([-200]), node)).to eq('200BC')
        end
      end

    end

  end
end
