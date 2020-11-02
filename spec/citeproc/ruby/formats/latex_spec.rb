require 'spec_helper'

module CiteProc
  module Ruby

    describe 'Formats::Latex#apply' do
      let(:format) { Format.load 'latex' }
      let(:node) { CSL::Style::Text.new }

      describe 'text-case formats' do
        it 'supports lowercase' do
          node[:'text-case'] = 'lowercase'
          expect(format.apply('Foo BAR', node)).to eq('foo bar')
        end
      end

      describe 'entity escaping' do
        it 'escapes entities in the original text' do
          node[:'text-case'] = 'lowercase'
          expect(format.apply('Foo & BAR', node)).to eq("foo \\& bar")
        end

        it 'does not not apply casing to escaped entities' do
          node[:'text-case'] = 'uppercase'
          expect(format.apply('Foo & BAR', node)).to eq("FOO \\& BAR")
        end
      end

      describe 'affixes' do
        it 'are added after text formats have been applied' do
          node[:prefix] = 'foo'
          node[:suffix] = 'ooo'
          node[:'font-style'] = 'italic'

          expect(format.apply('ooo', node)).to eq('foo\emph{ooo}ooo')
        end

        it 'are added before text formats have been applied for layout nodes' do
          layout = CSL::Style::Layout.new

          layout[:prefix] = 'foo'
          layout[:suffix] = 'ooo'
          layout[:'font-style'] = 'italic'

          expect(format.apply('ooo', layout)).to eq('\emph{foooooooo}')
        end
      end

      describe 'font-style' do
        it 'supports italic in both modes' do
          node[:'font-style'] = 'italic'

          expect(format.apply('foo bar', node)).to eq('\emph{foo bar}')

          format.config[:italic] = 'textit'
          expect(format.apply('foo bar', node)).to eq('\textit{foo bar}')
        end
      end

      describe 'font-weight' do
        it 'supports bold in both modes' do
          node[:'font-weight'] = 'bold'

          expect(format.apply('foo bar', node)).to eq('\textbf{foo bar}')

          format.config[:bold] = 'emph'
          expect(format.apply('foo bar', node)).to eq('\emph{foo bar}')
        end
      end

      describe 'display' do
        it 'is supported in an outer container' do
          node[:'display'] = 'block'
          node[:'text-decoration'] = 'underline'
          expect(format.apply('foo bar', node)).to eq('foo bar')

          node[:prefix] = '('
          expect(format.apply('foo bar', node)).to eq('(foo bar')
        end
      end

      describe 'bibliography formats' do
        let(:bibliography) do
          CiteProc::Bibliography.new do |b|
            b.push 'id-1', 'foo'
            b.push 'id-2', 'bar'
          end
        end

        it 'can be applied' do
          format.config[:bib_indent] = nil
          format.bibliography(bibliography)
actual =<<-EOS
\\begin{enumerate}
\\item  foo
\\item  bar
\\end{enumerate}
EOS
          expect(bibliography.join).to eq(actual.chomp)
        end
      end
    end

  end
end
