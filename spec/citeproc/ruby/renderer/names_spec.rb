# -*- coding: utf-8 -*-

require 'spec_helper'

module CiteProc
  module Ruby

    describe "Renderer#render_names" do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Names.new }

      let(:item) {
        i = CiteProc::CitationItem.new(:id => 'ID-1')
        i.data = CiteProc::Item.new(:id => 'ID-1')
        i
      }

      let(:poe) { people(:poe) }
      let(:philosophers) { CiteProc::Names.new('Plato and Socrates and Aristotle') }

      describe 'given an empty node' do
        it 'returns an empty string for an empty item' do
          expect(renderer.render(item, node)).to eq('')
        end

        it 'returns an empty string for an item with variables' do
          item.data.edition = 'foo'
          expect(renderer.render_names(item, node)).to eq('')
        end
      end

      describe 'given a single name for the variable' do
        before do
          item.data.author = poe
          node[:variable] = 'author'
        end

        it 'formats it in long form' do
          expect(renderer.render_names(item, node)).to eq('Edgar Allen Poe')
        end

        it 'supports nested name node options' do
          node << CSL::Style::Name.new(:form => 'short')
          expect(renderer.render_names(item, node)).to eq('Poe')
        end

        it 'supports nested label node' do
          node << CSL::Style::Label.new(:prefix => ' [', :suffix => ']')
          expect(renderer.render_names(item, node)).to eq('Edgar Allen Poe [author]')
        end
      end

      describe 'given multiple names for a single variable' do
        before do
          item.data.editor = philosophers
          node[:variable] = 'editor'
        end

        it 'formats them as a list' do
          expect(renderer.render_names(item, node)).to eq('Plato, Socrates, Aristotle')
        end

        it 'supports nested name node options' do
          node << CSL::Style::Name.new(:and => 'symbol')
          expect(renderer.render_names(item, node)).to eq('Plato, Socrates, & Aristotle')
        end

        it 'supports nested label node' do
          node << CSL::Style::Label.new(:prefix => ' (', :suffix => ')')
          expect(renderer.render_names(item, node)).to eq('Plato, Socrates, Aristotle (editors)')
        end
      end

      describe 'given multiple variables' do
        before do
          node[:variable] = 'author editor'
          node[:delimiter] = '; '
        end

        it 'renders all matching lists combinded using default delimiter' do
          expect(renderer.render_names(item, node)).to eq('')

          item.data.author = poe
          expect(renderer.render_names(item, node)).to eq('Edgar Allen Poe')

          item.data.editor = philosophers
          expect(renderer.render_names(item, node)).to eq('Edgar Allen Poe; Plato, Socrates, Aristotle')
        end

        it 'keeps the variable order' do
          item.data.author = poe
          item.data.editor = philosophers

          node[:variable] = 'editor author'
          expect(renderer.render_names(item, node)).to eq('Plato, Socrates, Aristotle; Edgar Allen Poe')
        end

        it 'supports labels' do
          item.data.author = poe
          item.data.editor = philosophers

          node << CSL::Style::Label.new(:prefix => ' (', :suffix => ')')

          expect(renderer.render_names(item, node)).to eq('Edgar Allen Poe (author); Plato, Socrates, Aristotle (editors)')
        end

        it 'resolves the editor translator special case' do
          renderer.format = :text

          node[:variable] = 'translator author editor'

          item.data.editor = 'Patrick F. Quinn and G. R. Thompson'
          item.data.author = poe

          node.name = { :and => 'symbol', :form => 'short' }
          node.label = { :prefix => ' (', :suffix => ')' }

          expect(renderer.render_names(item, node)).to eq('Poe (author); Quinn & Thompson (editors)')

          item.data.translator = poe
          expect(renderer.render_names(item, node)).to eq('Poe (translator); Poe (author); Quinn & Thompson (editors)')

          item.data.translator = 'Patrick F. Quinn and G. R. Thompson'

          expect(renderer.render(item, node)).to eq('Quinn & Thompson (editors & translators); Poe (author)')
        end

        it 'does not combine editors and translators if the editortranslator term is empty' do
          node[:variable] = 'editor translator'
          item.data.editor = poe
          item.data.translator = poe

          allow(renderer).to receive(:translate).and_call_original
          allow(renderer).to receive(:translate).with('editortranslator').and_return('')

          expect(renderer.render_names(item, node)).to eq('Edgar Allen Poe; Edgar Allen Poe')
        end
      end
    end

    describe "Renderer#render_name" do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Name.new }

      let(:poe) { people(:poe) }
      let(:philosophers) { CiteProc::Names.new('Plato and Socrates and Aristotle') }

      describe 'given an empty node' do
        it 'returns an empty string given no names' do
          expect(renderer.render_name(CiteProc::Names.new, node)).to eq('')
        end

        it 'formats the given name in long form' do
          expect(renderer.render_name(poe, node)).to eq('Edgar Allen Poe')
        end

        it 'formats multiple names delimitted by commas' do
          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, Aristotle')
        end
      end

      describe 'given a node with and "and" attribute' do
        it 'inserts a delimited connector' do
          node[:and] = 'symbol'
          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, & Aristotle')

          node[:and] = 'text'
          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, and Aristotle')
        end
      end

      describe 'given a node with affixes and formatting' do
        it 'formats each name and encloses all names in the affixes' do
          renderer.format = 'html'
          node.merge! :prefix => '(', :suffix => ')', :'font-style' => 'italic', :and => 'text'

          expect(renderer.render_name(philosophers.take(2), node)).to eq('(<i>Plato</i> and <i>Socrates</i>)')
        end
      end

      describe 'given terms of scripts without spaces' do
        it 'adds no spaces around the and term' do
          node[:and] = 'text'
          allow(renderer).to receive(:translate).with('and').and_return("ו\u2008")

          names = CiteProc::Names.new({ :family => 'תפוח' }, { :family => 'תפוז' })
          expect(renderer.render_name(names, node)).to eq("תפוחו\u2008תפוז")
        end

        it 'adds no space before the et-al term' do
          node[:'et-al-min'] = 3
          node[:'et-al-use-first'] = 1
          allow(renderer).to receive(:translate).with('et-al').and_return('等')

          expect(renderer.render_name(philosophers, node)).to eq('Plato等')
        end
      end

      describe 'given a node with delimier-precedes-last' do
        it 'inserts final delimiter only for three or more names when set to "contextual"' do
          node.delimiter_contextually_precedes_last!
          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, Aristotle')

          node[:and] = 'text'
          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, and Aristotle')

          expect(renderer.render_name(philosophers.take(2), node)).to eq('Plato and Socrates')

          node[:and] = nil
          expect(renderer.render_name(philosophers.take(2), node)).to eq('Plato, Socrates')
        end

        it 'inserts final delimiter when set to "always"' do
          node.delimiter_always_precedes_last!

          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, Aristotle')

          node[:and] = 'text'
          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, and Aristotle')

          expect(renderer.render_name(philosophers.take(2), node)).to eq('Plato, and Socrates')

          node[:and] = nil
          expect(renderer.render_name(philosophers.take(2), node)).to eq('Plato, Socrates')
        end

        it 'never inserts final delimiter when set to "never" (unless there is no "and")' do
          node.delimiter_never_precedes_last!

          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, Aristotle')
          expect(renderer.render_name(philosophers.take(2), node)).to eq('Plato, Socrates')

          node[:and] = 'text'
          expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates and Aristotle')
          expect(renderer.render_name(philosophers.take(2), node)).to eq('Plato and Socrates')
        end

        it 'supports only-after-inverted-name rule' do
          names = CiteProc::Names.new('Doe, J. and Smith, S. and Williams, T.')
          node.delimiter_precedes_last_after_inverted_name!

          # always delimit when there is no and!
          expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith, T. Williams')
          expect(renderer.render_name(names.take(2), node)).to eq('J. Doe, S. Smith')

          node[:and] = 'text'
          expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith and T. Williams')
          expect(renderer.render_name(names.take(2), node)).to eq('J. Doe and S. Smith')

          node[:'name-as-sort-order'] = 'first'
          expect(renderer.render_name(names, node)).to eq('Doe, J., S. Smith and T. Williams')
          expect(renderer.render_name(names.take(2), node)).to eq('Doe, J., and S. Smith')

          node[:'name-as-sort-order'] = 'all'
          expect(renderer.render_name(names, node)).to eq('Doe, J., Smith, S., and Williams, T.')
          expect(renderer.render_name(names.take(2), node)).to eq('Doe, J., and Smith, S.')
        end

        it 'does not insert the final delimiter after literal names for the only-after-inverted-name rule' do
          names = CiteProc::Names.new({ :literal => 'Productivity Commission' }, { :literal => 'Treasury' })
          node.delimiter_precedes_last_after_inverted_name!
          node[:'name-as-sort-order'] = 'all'
          node[:and] = 'text'

          expect(renderer.render_name(names, node)).to eq('Productivity Commission and Treasury')
        end
      end

      describe 'truncation of name lists' do
        let(:names) { CiteProc::Names.new('Doe, J. and Smith, S. and Williams, T.') }

        it 'supports et-al formatting via an et-al node' do
          node[:'et-al-min'] = 3
          node[:'et-al-use-first'] = 2

          others = CSL::Style::EtAl.new(:prefix => '!!')
          allow(node).to receive(:et_al).and_return(others)

          expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith, !!et al.')

          others[:term] = 'and others'
          expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith, !!and others')
        end

        it 'skips empty et-al terms' do
          node[:'et-al-min'] = 3
          node[:'et-al-use-first'] = 2
          allow(renderer).to receive(:translate).with('et-al').and_return('')

          expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith')
        end

        it 'supports et-al-use-last' do
          node[:'et-al-min'] = 3
          node[:'et-al-use-first'] = 2
          node[:'et-al-use-last'] = true

          # truncated list must be at least two names short!
          expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith, et al.')

          node[:'et-al-use-first'] = 1
          expect(renderer.render_name(names, node)).to eq('J. Doe, … T. Williams')
        end

        describe 'with default delimiter settings' do
          it 'truncates the list if it matches or exceeds et-al-min' do
            node[:'et-al-min'] = 3
            node[:'et-al-use-first'] = 2

            expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith, et al.')

            node[:'et-al-use-first'] = 1
            expect(renderer.render_name(names, node)).to eq('J. Doe et al.')
          end

          it 'does not truncate the list if it is less than et-al-min' do
            node[:'et-al-min'] = 4
            node[:'et-al-use-first'] = 2

            expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith, T. Williams')
          end
        end

        describe 'with delimiter-precedes-et-al set' do
          it 'inserts delimiter only for two or more names when set to "contextual" or nil' do
            node.truncate_when! 3
            node.truncate_at! 2

            # default behaviour should match contextual!
            expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, et al.')

            node.truncate_at! 1
            expect(renderer.render_name(philosophers, node)).to eq('Plato et al.')

            # set contextual explicitly
            node.delimiter_contextually_precedes_et_al!
            expect(renderer.render_name(philosophers, node)).to eq('Plato et al.')

            node.truncate_at! 2
            expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, et al.')
          end

          it 'inserts delimiter when set to "always"' do
            node.truncate_when! 3
            node.truncate_at! 2

            node.delimiter_always_precedes_et_al!
            expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates, et al.')

            node.truncate_at! 1
            expect(renderer.render_name(philosophers, node)).to eq('Plato, et al.')
          end

          it 'never inserts delimiter when set to "never"' do
            node.truncate_when! 3
            node.truncate_at! 2

            node.delimiter_never_precedes_et_al!
            expect(renderer.render_name(philosophers, node)).to eq('Plato, Socrates et al.')

            node.truncate_at! 1
            expect(renderer.render_name(philosophers, node)).to eq('Plato et al.')
          end

          it 'supports only-after-inverted-name rule' do
            node.truncate_when! 3
            node.truncate_at! 2

            node.delimiter_precedes_et_al_after_inverted_name!

            expect(renderer.render_name(names, node)).to eq('J. Doe, S. Smith et al.')

            node[:'name-as-sort-order'] = 'first'
            expect(renderer.render_name(names, node)).to eq('Doe, J., S. Smith et al.')

            node.truncate_at! 1
            expect(renderer.render_name(names, node)).to eq('Doe, J., et al.')

            node[:'name-as-sort-order'] = 'all'
            expect(renderer.render_name(names, node)).to eq('Doe, J., et al.')

            node.truncate_at! 2
            expect(renderer.render_name(names, node)).to eq('Doe, J., Smith, S., et al.')
          end
        end
      end

      describe 'name-part formatting' do
        let(:part) { CSL::Style::NamePart.new(:'text-case' => 'uppercase') }
        before { node.parts << part }

        it 'supports family name formatting' do
          part[:name] = 'family'
          expect(renderer.render_name(poe, node)).to eq('Edgar Allen POE')
        end

        it 'family part includes non-demoted particles' do
          part[:name] = 'family'

          expect(renderer.render_name(people(:la_fontaine), node)).to eq('Jean de LA FONTAINE')
          expect(renderer.render_name(people(:humboldt), node)).to eq('Alexander von HUMBOLDT')
          expect(renderer.render_name(people(:van_gogh), node)).to eq('Vincent VAN GOGH')
        end

        it 'family part affixes enclose particles and suffix for non-inverted names' do
          part.merge! :name => 'family', :prefix => '(', :suffix => ')'

          la_fontaine = people(:la_fontaine)
          la_fontaine[0].suffix = 'Jr.'

          expect(renderer.render_name(la_fontaine, node)).to eq('Jean (de LA FONTAINE Jr.)')

          node.all_names_as_sort_order!
          expect(renderer.render_name(la_fontaine, node)).to eq('(FONTAINE), Jean de LA, Jr.')

          la_fontaine[0].never_demote_particle!
          expect(renderer.render_name(la_fontaine, node)).to eq('(LA FONTAINE), Jean de, Jr.')
        end

        it 'formats particles and names separately' do
          renderer.format = 'html'
          part.merge! :name => 'family', :'font-weight' => 'bold'
          part[:'text-case'] = nil

          expect(renderer.render_name(people(:van_gogh), node)).to eq('Vincent <b>van</b> <b>Gogh</b>')
        end

        it 'supports given name formatting' do
          part[:name] = 'given'
          expect(renderer.render_name(poe, node)).to eq('EDGAR ALLEN Poe')
        end

        it 'given part includes particles' do
          part[:name] = 'given'

          expect(renderer.render_name(people(:la_fontaine), node)).to eq('JEAN DE La Fontaine')
          expect(renderer.render_name(people(:humboldt), node)).to eq('ALEXANDER VON Humboldt')
          expect(renderer.render_name(people(:van_gogh), node)).to eq('VINCENT van Gogh')
        end

        it 'given part affixes enclose demoted particles' do
          part.merge! :name => 'given', :prefix => '(', :suffix => ')'

          la_fontaine = people(:la_fontaine)

          expect(renderer.render_name(la_fontaine, node)).to eq('(JEAN) DE La Fontaine')

          node.all_names_as_sort_order!
          expect(renderer.render_name(la_fontaine, node)).to eq('Fontaine, (JEAN DE La)')

          la_fontaine[0].never_demote_particle!
          expect(renderer.render_name(la_fontaine, node)).to eq('La Fontaine, (JEAN DE)')
        end

        it 'does not add a space after name-part affixes ending in a space' do
          part.merge! :name => 'given', :suffix => "\u00a0"
          part[:'text-case'] = nil

          expect(renderer.render_name(poe, node)).to eq("Edgar Allen\u00a0Poe")
        end

        it 'formats literal names like family names' do
          part.merge! :name => 'family', :prefix => '(', :suffix => ')'
          names = CiteProc::Names.new(:literal => 'São Paulo (Estado)')

          expect(renderer.render_name(names, node)).to eq('(SÃO PAULO (ESTADO))')
        end

        it 'does not alter the passed-in name object' do
          part[:name] = 'family'
          expect(renderer.render_name(poe, node)).to eq('Edgar Allen POE')
          expect(poe.to_s).to eq('Edgar Allen Poe')
        end
      end
    end

    describe "Renderer#render_sort" do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Name.new }

      let(:key) { CSL::Style::Sort::Key.new }

      it 'keeps leading non-ASCII letters in family names' do
        ecrivain = CiteProc::Names.new('Écrivain, Jean')
        expect(renderer.render_sort(ecrivain, node, key)).to eq('Jean Écrivain')
        expect(renderer.render_sort(people(:papadopoulos), node, key)).to eq('Γιώργος Παπαδόπουλος')
      end

      it 'strips leading punctuation from family names' do
        ecrivain = CiteProc::Names.new('Écrivain, Jean')
        ecrivain[0].family = '"Écrivain'

        papadopoulos = people(:papadopoulos)
        papadopoulos[0].family = '«Παπαδόπουλος'

        expect(renderer.render_sort(ecrivain, node, key)).to eq('Jean Écrivain')
        expect(renderer.render_sort(papadopoulos, node, key)).to eq('Γιώργος Παπαδόπουλος')
      end

      it 'strips square brackets from family names' do
        ecrivain = CiteProc::Names.new('Écrivain, Jean')
        ecrivain[0].family = '[Écrivain]'

        papadopoulos = people(:papadopoulos)
        papadopoulos[0].family = '[Παπαδόπουλος]'

        expect(renderer.render_sort(ecrivain, node, key)).to eq('Jean Écrivain')
        expect(renderer.render_sort(papadopoulos, node, key)).to eq('Γιώργος Παπαδόπουλος')
      end
    end
  end
end
