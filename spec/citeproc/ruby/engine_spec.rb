# -*- encoding: utf-8 -*-

require 'spec_helper'

module CiteProc
  module Ruby

  describe 'The CiteProc-Ruby Engine' do
    let(:cp) { CiteProc::Processor.new :style => 'apa', :format => 'text' }
    let(:engine) { cp.engine }

    it 'registers itself as "citeproc-ruby"' do
      expect(CiteProc::Engine.available).to include('citeproc-ruby')
    end

    it 'is the default engine' do
      expect(CiteProc::Engine.default).to equal(CiteProc::Ruby::Engine)
      expect(engine).to be_a(CiteProc::Ruby::Engine)
    end

    describe '#bibliography' do

      describe 'when there are no items in the processor' do
        it 'returns an empty bibliography for any selector' do
          expect(cp.bibliography()).to be_empty
          expect(cp.bibliography(:all => {})).to be_empty
          expect(cp.bibliography(:none => {})).to be_empty
        end
      end

    end

    describe '#render' do

      describe 'when there are no items in the processor' do
      end

      describe 'when there are items in the processor' do
        before(:each) do
          cp << items(:grammatology).data
          cp << items(:knuth1968).data
          cp << items(:difference).data
          cp << items(:literal_date).data
        end

        it 'renders the reference for the given id' do
          expect(cp.render(:bibliography, :id => 'grammatology')).to eq(['Derrida, J. (1976). Of Grammatology (corrected ed.). Baltimore: Johns Hopkins University Press.'])
          expect(cp.render(:citation, :id => 'grammatology', :locator => '3-4')).to eq('(Derrida, 1976, pp. 3-4)')
          expect(cp.render(:bibliography, :id => 'knuth1968')).to eq(['Knuth, D. (1968). The art of computer programming (Vol. 1). Boston: Addison-Wesley.'])

          node = cp.engine.style.macros['author']
          (node > 'names' > 'name')[:initialize] = 'false'

          cp.engine.format = 'html'
          expect(cp.render(:bibliography, :id => 'knuth1968')).to eq(['Knuth, Donald. (1968). <i>The art of computer programming</i> (Vol. 1). Boston: Addison-Wesley.'])

          expect(cp.render(:citation, :id => 'knuth1968', :locator => '23')).to eq('(Knuth, 1968, p. 23)')
        end

        it 'overrides locales if the processor option is set' do
          expect(cp.render(:bibliography, :id => 'difference')).to eq(['Derrida, J. (1967). L’écriture et la différence (1st ed.). Paris: Éditions du Seuil.'])

          cp.options[:allow_locale_overrides] = true
          expect(cp.render(:bibliography, :id => 'difference')).to eq(['Derrida, J. (1967). L’écriture et la différence (1ʳᵉ éd.). Paris: Éditions du Seuil.'])
        end

        it 'can handle literal dates' do
          expect(cp.render(:bibliography, :id => 'literal_date')).to eq(['Derrida, J. (sometime in 1967). L’écriture et la différence (1st ed.). Paris: Éditions du Seuil.'])
        end
      end
    end

    describe '#process' do
      describe 'when there are no items in the processor' do
      end

      describe 'when there are items in the processor' do
        before(:each) do
          cp << items(:grammatology).data
          cp << items(:knuth1968).data
        end

        it 'renders the citation for the given id' do
          expect(cp.process(:id => 'knuth1968', :locator => '23')).to eq('(Knuth, 1968, p. 23)')
        end

        it 'combines and sorts multiple cite items' do
          expect(cp.process([
            {:id => 'knuth1968', :locator => '23'},
            {:id => 'grammatology', :locator => '11-14'}
          ])).to eq('(Derrida, 1976, pp. 11-14; Knuth, 1968, p. 23)')
        end
      end
    end

  end

  end
end
