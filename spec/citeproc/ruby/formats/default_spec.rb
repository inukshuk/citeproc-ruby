# encoding: utf-8

require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Formats::Text#apply' do
      let(:format) { Format.load 'text' }
      let(:node) { CSL::Style::Text.new }

      it 'returns an empty string if input is nil' do
        expect(format.apply(nil, node)).to eq('')
      end

      it 'returns the string unchanged if empty' do
        input = ''
        expect(format.apply(input, node)).to be_equal(input)
        expect(input).to eq('')
      end

      it 'returns the string unchanged if node is nil' do
        input = 'foo'
        expect(format.apply(input, nil)).to be_equal(input)
        expect(input).to eq('foo')
      end

      it 'supports localized quotes' do
        locale = double(:locale)
        allow(locale).to receive(:punctuation_in_quotes?).and_return(true)
        allow(locale).to receive(:quote).and_return('bar')

        node[:quotes] = true

        expect(format.apply('foo', node, locale)).to eq('bar')
      end

      it 'disregards localized closing quotes when squeezing affixes' do
        locale = double(:locale)
        allow(locale).to receive(:punctuation_in_quotes?).and_return(true)
        allow(locale).to receive(:quote) { |t| %("#{t}") }
        allow(locale).to receive(:t) { |t| t == 'close-quote' ? '"' : "'" }

        node[:quotes] = true
        node[:suffix] = '.'

        expect(format.apply('foo', node, locale)).to eq('"foo."')
        expect(format.apply("'foo'", node, locale)).to eq("\"'foo.'\"")
      end

      describe 'text-case formats' do
        it 'supports lowercase' do
          node[:'text-case'] = 'lowercase'
          expect(format.apply('Foo BAR', node)).to eq('foo bar')
        end

        it 'supports lowercase for non-ascii letters' do
          node[:'text-case'] = 'lowercase'
          expect(format.apply('SCHÖN!', node)).to eq('schön!')
        end

        it 'supports uppercase' do
          node[:'text-case'] = 'uppercase'
          expect(format.apply('Foo BAR', node)).to eq('FOO BAR')
        end

        it 'supports uppercase for non-ascii letters' do
          node[:'text-case'] = 'uppercase'
          expect(format.apply('schön!', node)).to eq('SCHÖN!')
        end

        it 'supports uppercase and lowercase for Turkic languages' do
          node[:'text-case'] = 'uppercase'
          expect(format.apply('ic and ıd', node, nil, 'tr')).to eq('İC AND ID')
          expect(format.apply('ic and ıd', node, nil, 'en')).to eq('IC AND ID')

          node[:'text-case'] = 'lowercase'
          expect(format.apply('İC AND ID', node, nil, 'tr')).to eq('ic and ıd')
        end

        it 'does not alter the original string' do
          node[:'text-case'] = 'lowercase'
          input = 'fooBar'

          expect(format.apply(input, node)).to eq('foobar')
          expect(input).to eq('fooBar')
        end

        it 'supports capitalize-first' do
          node[:'text-case'] = 'capitalize-first'

          expect(format.apply('foo bar', node)).to eq('Foo bar')
          expect(format.apply('Foo bar', node)).to eq('Foo bar')
          expect(format.apply('!foo bar', node)).to eq('!Foo bar')
          expect(format.apply('én foo bar', node)).to eq('Én foo bar')
        end

        it 'supports capitalize-first with ordinal numbers' do
          node[:'text-case'] = 'capitalize-first'

          expect(format.apply('1st edition', node)).to eq('1st edition')
          expect(format.apply('first edition', node)).to eq('First edition')
        end

        it 'supports capitalize-all' do
          node[:'text-case'] = 'capitalize-all'

          expect(format.apply('foo bar', node)).to eq('Foo Bar')
          expect(format.apply('!foo bar', node)).to eq('!Foo Bar')
          expect(format.apply('én foo bar', node)).to eq('Én Foo Bar')
        end

        it 'supports sentence case' do
          node[:'text-case'] = 'sentence'

          expect(format.apply('FOO bar', node)).to eq('Foo bar')
          expect(format.apply('foo Bar BAR', node)).to eq('Foo Bar Bar')
          expect(format.apply('én Foo bar', node)).to eq('Én Foo bar')
        end

        it 'supports title case' do
          node[:'text-case'] = 'title'

          expect(format.apply('The adventures of Huckleberry Finn', node)).to eq('The Adventures of Huckleberry Finn')
          expect(format.apply('This IS a pen that is a smith pencil', node)).to eq('This IS a Pen That Is a Smith Pencil')
          expect(format.apply('of mice and men', node)).to eq('Of Mice and Men')
          expect(format.apply('history of the word the', node)).to eq('History of the Word The')
          expect(format.apply('faster than the speed of sound', node)).to eq('Faster than the Speed of Sound')
          expect(format.apply('on the drug-resistance of enteric bacteria', node)).to eq('On the Drug-Resistance of Enteric Bacteria')
          expect(format.apply("The Mote in God's eye", node)).to eq("The Mote in God's Eye")
          expect(format.apply("The Mote in God eye", node)).to eq("The Mote in God Eye")
          expect(format.apply("Music community mourns death of one of its leaders", node)).to eq("Music Community Mourns Death of One of Its Leaders")
          expect(format.apply("Pride and Prejudice", node)).to eq("Pride and Prejudice")
          expect(format.apply("Check the page: easybib.com", node)).to eq("Check the Page: Easybib.com")
          expect(format.apply("Dogs life.obviously the best guide for pet owners", node)).to eq("Dogs Life.obviously the Best Guide for Pet Owners")
        end

        it 'capitalizes stop words after a colon' do
          node[:'text-case'] = 'title'
          expect(format.apply('out-of-fashion initiatives: a second story', node)).to eq('Out-of-Fashion Initiatives: A Second Story')
        end

        it 'capitalizes stop words before a hyphen' do
          node[:'text-case'] = 'title'
          expect(format.apply('employee pro-environmental behavior', node)).to eq('Employee Pro-Environmental Behavior')
        end

        it 'does not capitalize words after apostrophes' do
          node[:'text-case'] = 'title'
          expect(format.apply('nobody knows you’re a dog', node)).to eq('Nobody Knows You’re a Dog')
        end

        it 'does not capitalize particles and yet' do
          node[:'text-case'] = 'title'
          expect(format.apply('antiquités de l’Égypte yet again', node)).to eq('Antiquités de l’Égypte yet Again')
        end

        it 'does not change words in mixed case' do
          node[:'text-case'] = 'title'
          expect(format.apply('iPad is a thing', node)).to eq('iPad Is a Thing')
        end

        describe 'title case and languages' do
          before { node[:'text-case'] = 'title' }

          let(:en) { CSL::Locale.new('en-US') }
          let(:de) { CSL::Locale.new('de-DE') }

          it 'applies to items in English' do
            expect(format.apply('of mice and men', node, en, 'en')).to eq('Of Mice and Men')
            expect(format.apply('of mice and men', node, de, 'en-GB')).to eq('Of Mice and Men')
          end

          it 'applies to items without language in English locales' do
            expect(format.apply('of mice and men', node, en, '')).to eq('Of Mice and Men')
            expect(format.apply('of mice and men', node, en)).to eq('Of Mice and Men')
          end

          it 'does not apply to items in other languages' do
            expect(format.apply('syntax und stilistik', node, en, 'de')).to eq('syntax und stilistik')
            expect(format.apply('syntax und stilistik', node, en, 'english')).to eq('syntax und stilistik')
          end

          it 'does not apply to items without language in other locales' do
            expect(format.apply('syntax und stilistik', node, de)).to eq('syntax und stilistik')
          end
        end
      end

      describe 'strip-periods' do
        before { node[:'strip-periods'] = true }

        it 'strips all periods from the output' do
          expect(format.apply('hello there...! how.are.you?', node)).to eq('hello there! howareyou?')
          expect(format.apply('foo bar!', node)).to eq('foo bar!')
        end

        it 'does not strip periods from affixes' do
          node[:prefix] = '...('
          node[:suffix] = ').'

          expect(format.apply('foo.bar.', node)).to eq('...(foobar).')
        end
      end

      describe 'affixes' do
        it 'are added after text formats have been applied' do
          node[:prefix] = 'foo'
          node[:suffix] = 'ooo'
          node[:'text-case'] = 'uppercase'

          expect(format.apply('ooo', node)).to eq('fooOOOooo')
        end

        it 'xml entities are not encoded' do
          node[:prefix] = '<'
          node[:suffix] = '>'
          expect(format.apply('x', node)).to eq('<x>')
        end


        it 'drop squeezable characters at start/end' do
          node[:suffix] = ' '

          expect(format.apply('foo', node)).to eq('foo ')
          expect(format.apply('foo ', node)).to eq('foo ')

          node[:suffix] = '. '
          expect(format.apply('foo', node)).to eq('foo. ')
          expect(format.apply('foo.', node)).to eq('foo. ')
          expect(format.apply('foo?', node)).to eq('foo? ')

          node[:prefix] = '.'
          expect(format.apply('foo', node)).to eq('.foo. ')
          expect(format.apply('.foo', node)).to eq('.foo. ')
          expect(format.apply(',foo', node)).to eq('.,foo. ')
        end
      end
    end

  end
end
