# -*- encoding: utf-8 -*-

require 'spec_helper'

module CiteProc
  module Ruby

    describe 'SortItems#compare_items' do
      let(:cp) { CiteProc::Processor.new :style => 'apa', :format => 'text' }
      let(:engine) { cp.engine }

      def sort(*strings)
        strings.sort { |a, b| engine.compare_items(a, b) }
      end

      it 'ignores case' do
        expect(sort('b', 'A', 'c')).to eq(['A', 'b', 'c'])
      end

      it 'ignores diacritics' do
        expect(sort('Zola', 'Öberg', 'Martin', 'Éluard', 'Klein', 'Ångström', 'Abel'))
          .to eq(['Abel', 'Ångström', 'Éluard', 'Klein', 'Martin', 'Öberg', 'Zola'])
      end

      it 'uses case folding' do
        expect(sort('Strasser', 'Straße')).to eq(['Straße', 'Strasser'])
      end

      it 'orders strings differing only in diacritics consistently' do
        expect(engine.compare_items('Muller', 'Müller')).to eq(-1)
        expect(engine.compare_items('Müller', 'Muller')).to eq(1)
        expect(engine.compare_items('Müller', 'Müller')).to eq(0)
      end

      describe 'when sorting case sensitively' do
        before { cp.options[:sort_case_sensitively] = true }

        it 'sorts upper case first' do
          expect(sort('b', 'A', 'a', 'B')).to eq(['A', 'a', 'B', 'b'])
        end

        it 'considers diacritics before case' do
          expect(sort('é', 'É', 'e', 'E')).to eq(['E', 'e', 'É', 'é'])
        end

        it 'ignores diacritics' do
          expect(sort('Zola', 'Éluard', 'Abel')).to eq(['Abel', 'Éluard', 'Zola'])
        end
      end
    end

  end
end
