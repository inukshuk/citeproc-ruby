require 'spec_helper'

module CiteProc
  module Ruby

    describe "Renderer#render_label" do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Label.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }

      describe 'given an empty node' do
        it 'returns an empty string for an empty item' do
          expect(renderer.render_label(item, node)).to eq('')
        end

        it 'returns an empty string for an item with variables' do
          item.data.edition = 'foo'
          expect(renderer.render_label(item, node)).to eq('')
        end
      end


      # page

      describe "when the node's variable is set to :page" do
        before(:each) { node[:variable] = :page }

        describe "for an item with no page value" do
          it 'returns an empty string' do
            expect(renderer.render_label(item, node)).to eq('')
          end
        end

        describe 'for an item with a page value' do
          it 'returns the singular label for a number' do
            item.write_attribute :page, '23'
            expect(renderer.render_label(item, node)).to eq('page')
          end

          it 'returns the plural label for a page-range' do
            item.write_attribute :page, '23-24'
            expect(renderer.render_label(item, node)).to eq('pages')
          end

          it 'returns the plural label for multiple pages' do
            item.write_attribute :page, '23 & 24'
            expect(renderer.render_label(item, node)).to eq('pages')

            item.write_attribute :page, '23, 24, 25'
            expect(renderer.render_label(item, node)).to eq('pages')
          end

          describe 'when pluralization is contextual' do
            before(:each) { node[:plural] = 'contextual' }

            it 'returns the singular label for a number' do
              item.write_attribute :page, '23'
              expect(renderer.render_label(item, node)).to eq('page')
            end

            it 'returns the plural label for a page-range' do
              item.write_attribute :page, '23-24'
              expect(renderer.render_label(item, node)).to eq('pages')
            end
          end

          describe 'when pluralization is set to "always"' do
            before(:each) { node[:plural] = 'always' }

            it 'returns the singular label for a number' do
              item.write_attribute :page, '1'
              expect(renderer.render_label(item, node)).to eq('pages')
            end

            it 'returns the plural label for a page-range' do
              item.write_attribute :page, '1-3'
              expect(renderer.render_label(item, node)).to eq('pages')
            end
          end

          describe 'when pluralization is set to "never"' do
            before(:each) { node[:plural] = 'never' }

            it 'returns the singular label for a number' do
              item.write_attribute :page, '1'
              expect(renderer.render_label(item, node)).to eq('page')
            end

            it 'returns the plural label for a page-range' do
              item.write_attribute :page, '1-3'
              expect(renderer.render_label(item, node)).to eq('page')
            end
          end
        end
      end


      # number-of-pages variable

      describe "when the node's variable is set to :'number-of-pages'" do
        before(:each) { node[:variable] = 'number-of-pages' }

        describe "for an item with no 'number-of-pages' value" do
          it 'returns an empty string' do
            expect(renderer.render_label(item, node)).to eq('')
          end
        end

        describe "for an item with a 'number-of-pages' value" do
          it 'returns the singular label for number 1' do
            item.data[:'number-of-pages'] = 1
            expect(renderer.render_label(item, node)).to eq('page')
          end

          it 'returns the plural label for numbers higher than 1' do
            item.data[:'number-of-pages'] = '2'
            expect(renderer.render_label(item, node)).to eq('pages')

            item.data[:'number-of-pages'] = 42
            expect(renderer.render_label(item, node)).to eq('pages')
          end

          describe 'when pluralization is set to "contextual"' do
            before(:each) { node[:plural] = 'contextual' }

            it 'returns the singular label for number 1' do
              item.data[:'number-of-pages'] = '1'
              expect(renderer.render_label(item, node)).to eq('page')
            end

            it 'returns the plural label for numbers higher than 1' do
              item.data[:'number-of-pages'] = '2'
              expect(renderer.render_label(item, node)).to eq('pages')

              item.data[:'number-of-pages'] = 42
              expect(renderer.render_label(item, node)).to eq('pages')
            end
          end

          describe 'when pluralization is set to "always"' do
            before(:each) { node[:plural] = 'always' }

            it 'returns the singular label for number 1' do
              item.data[:'number-of-pages'] = 1
              expect(renderer.render_label(item, node)).to eq('pages')
            end

            it 'returns the plural label for numbers higher than 1' do
              item.data[:'number-of-pages'] = '2'
              expect(renderer.render_label(item, node)).to eq('pages')

              item.data[:'number-of-pages'] = 42
              expect(renderer.render_label(item, node)).to eq('pages')
            end
          end

          describe 'when pluralization is set to "never"' do
            before(:each) { node[:plural] = 'never' }

            it 'returns the singular label for number 1' do
              item.data[:'number-of-pages'] = 1
              expect(renderer.render_label(item, node)).to eq('page')
            end

            it 'returns the plural label for numbers higher than 1' do
              item.data[:'number-of-pages'] = '2'
              expect(renderer.render_label(item, node)).to eq('page')

              item.data[:'number-of-pages'] = 42
              expect(renderer.render_label(item, node)).to eq('page')
            end
          end
        end
      end

      # number-of-volumes variable

      describe "when the node's variable is set to :'number-of-volumes'" do
        before(:each) { node[:variable] = 'number-of-volumes' }

        describe "for an item with a 'number-of-volumes' value" do
          it 'returns the singular label for number 1' do
            item.data[:'number-of-volumes'] = 1
            expect(renderer.render_label(item, node)).to eq('volume')
          end

          it 'returns the plural label for numbers higher than 1' do
            item.data[:'number-of-volumes'] = '2'
            expect(renderer.render_label(item, node)).to eq('volumes')

            item.data[:'number-of-volumes'] = 42
            expect(renderer.render_label(item, node)).to eq('volumes')
          end
        end
      end

      # locators

      describe "when the node's variable is set to another locator" do
        before(:each) { node[:variable] = 'locator' }

        describe "for an item with a locator and label" do
          it "returns the singular label for a single number" do
            item.locator = 2
            item.label = 'book'
            expect(renderer.render_label(item, node)).to eq('book')
          end

          it "returns the plural label for multiple numbers" do
            item.locator = '23 & 4'
            item.label = 'book'
            expect(renderer.render_label(item, node)).to eq('books')
          end
        end
      end

    end # render_label
  end
end
