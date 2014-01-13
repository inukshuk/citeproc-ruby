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
            renderer.render(item, node).should == '01/27/2012'
          end
        end
      end

      describe 'static rendering' do
        let(:node) { CSL::Style::Date.new(:variable => 'issued') }

        describe 'given an item issued on January 27th, 2012' do
          before(:each) { item.data[:issued] = '2012-01-27' }

          it 'returns an empty string by default' do
            renderer.render_date(item, node).should == ''
          end

          describe 'and given a node with a year part' do
            before(:each) { node << CSL::Style::DatePart.new(:name => 'year') }

            it 'returns the year as "2012"' do
              renderer.render_date(item, node).should == '2012'
            end

            describe 'and a day part' do
              before(:each) { node << CSL::Style::DatePart.new(:name => 'day') }

              it 'returns "201227"' do
                renderer.render_date(item, node).should == '201227'
              end

              it 'applies delimiters when set on the node' do
                node[:delimiter] = '/'
                renderer.render_date(item, node).should == '2012/27'
              end

              describe 'and a month part' do
                before(:each) { node << CSL::Style::DatePart.new(:name => 'month') }

                it 'returns "201227January"' do
                  renderer.render_date(item, node).should == '201227January'
                end

                it 'returns "2012/27/01" when the month form set to "numeric-leading-zeros" and the node has a delimiter "/"' do
                  node.parts.last[:form] = 'numeric-leading-zeros'
                  node[:delimiter] = '/'
                  renderer.render_date(item, node).should == '2012/27/01'
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
        renderer.render_date_part(CiteProc::Date.today, node).should == ''
      end

      describe 'when the name is set to "day"' do
        before(:each) { node[:name] = 'day' }

        it 'renders the day as number by default' do
          renderer.render_date_part(today, node).should == today.day.to_s
        end

        it 'renders the day as an ordinal number when the form is set to "ordinal"' do
          node[:form] = 'ordinal'
          renderer.render_date_part(independence, node).should == '4th'

          renderer.locale.limit_day_ordinals!
          renderer.render_date_part(independence, node).should == '4'

          independence.day = 1
          renderer.render_date_part(independence, node).should == '1st'
        end
      end

      describe 'when the name is set to "month"' do
        before(:each) { node[:name] = 'month' }

        it "renders the month's full name by default" do
          renderer.render_date_part(january, node).should == 'January'
          renderer.render_date_part(december, node).should == 'December'
        end

        it "renders the month's full name as the long form" do
          node[:form] = 'long'
          renderer.render_date_part(january, node).should == 'January'
        end

        it "renders the month's short name as the short form" do
          node[:form] = 'short'
          renderer.render_date_part(january, node).should == 'Jan.'
        end

        it 'renders the month as number as the numeric form' do
          node[:form] = 'numeric'
          renderer.render_date_part(january, node).should == '1'
        end

        it 'renders the month as number with a leading zero when form is set to numeric-leading-zeros' do
          node[:form] = 'numeric-leading-zeros'
          renderer.render_date_part(january, node).should == '01'
          renderer.render_date_part(december, node).should == '12'
        end

        it 'renders the name of the season when a season is set' do
          january.season = 4
          renderer.render_date_part(january, node).should == 'Winter'
        end
      end

      describe 'when the name is set to "year"' do
        before(:each) { node[:name] = 'year' }

        it 'renders the full year by default' do
          renderer.render_date_part(today, node).should == today.year.to_s
        end

        it 'renders the full year when form is set to long' do
          node[:form] = 'long'
          renderer.render_date_part(january, node).should == '2012'
        end

        it 'renders the short year when form is set to short' do
          node[:form] = 'short'
          renderer.render_date_part(january, node).should == '12'
        end

        it 'adds AD if applicable' do
          renderer.render_date_part(CiteProc::Date.new([200]), node) == '200AD'
        end

        it 'adds BC if applicable' do
          renderer.render_date_part(CiteProc::Date.new([-200]), node) == '200BC'
        end
      end

    end

  end
end
