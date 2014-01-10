# encoding: utf-8

require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Formats::Text#apply' do
      let(:format) { Format.load 'text' }
      let(:node) { CSL::Style::Text.new }

      it 'returns an empty string if input is nil' do
        format.apply(nil, node).should == ''
      end

      it 'returns the string unchanged if empty' do
        input = ''
        format.apply(input, node).should be_equal(input)
        input.should == ''
      end

      it 'returns the string unchanged if node is nil' do
        input = 'foo'
        format.apply(input, nil).should be_equal(input)
        input.should == 'foo'
      end

      describe 'text-case formats' do
        it 'supports lowercase' do
          node[:'text-case'] = 'lowercase'
          format.apply('Foo BAR', node).should == 'foo bar'
        end

        it 'supports lowercase for non-ascii letters' do
          node[:'text-case'] = 'lowercase'
          format.apply('SCHÖN!', node).should == 'schön!'
        end

        it 'supports uppercase' do
          node[:'text-case'] = 'uppercase'
          format.apply('Foo BAR', node).should == 'FOO BAR'
        end

        it 'supports uppercase for non-ascii letters' do
          node[:'text-case'] = 'uppercase'
          format.apply('schön!', node).should == 'SCHÖN!'
        end

        it 'does not alter the original string' do
          node[:'text-case'] = 'lowercase'
          input = 'fooBar'

          format.apply(input, node).should == 'foobar'
          input.should == 'fooBar'
        end

        it 'supports capitalize-first' do
          node[:'text-case'] = 'capitalize-first'

          format.apply('foo bar', node).should == 'Foo bar'
          format.apply('Foo bar', node).should == 'Foo bar'
          format.apply('!foo bar', node).should == '!Foo bar'
          format.apply('én foo bar', node).should == 'Én foo bar'
        end

        it 'supports capitalize-all' do
          node[:'text-case'] = 'capitalize-all'

          format.apply('foo bar', node).should == 'Foo Bar'
          format.apply('!foo bar', node).should == '!Foo Bar'
          format.apply('én foo bar', node).should == 'Én Foo Bar'
        end

        it 'supports sentence case' do
          node[:'text-case'] = 'sentence'

          format.apply('FOO bar', node).should == 'Foo bar'
          format.apply('foo Bar BAR', node).should == 'Foo Bar Bar'
          format.apply('én Foo bar', node).should == 'Én Foo bar'
        end
      end

      describe 'strip-periods' do
        before { node[:'strip-periods'] = true }

        it 'strips all periods from the output' do
          format.apply('hello there...! how.are.you?', node).should == 'hello there! howareyou?'
          format.apply('foo bar!', node).should == 'foo bar!'
        end

        it 'does not strip periods from affixes' do
          node[:prefix] = '...('
          node[:suffix] = ').'

          format.apply('foo.bar.', node).should == '...(foobar).'
        end
      end

      describe 'affixes' do
        it 'are added after text formats have been applied' do
          node[:prefix] = 'foo'
          node[:suffix] = 'ooo'
          node[:'text-case'] = 'uppercase'

          format.apply('ooo', node).should == 'fooOOOooo'
        end
      end
    end

  end
end
