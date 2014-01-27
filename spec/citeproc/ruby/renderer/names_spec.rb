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
          renderer.render(item, node).should == ''
        end

        it 'returns an empty string for an item with variables' do
          item.data.edition = 'foo'
          renderer.render_names(item, node).should == ''
        end
      end

      describe 'given a single name for the variable' do
        before do
          item.data.author = poe
          node[:variable] = 'author'
        end

        it 'formats it in long form' do
          renderer.render_names(item, node).should == 'Edgar Allen Poe'
        end

        it 'supports nested name node options' do
          node << CSL::Style::Name.new(:form => 'short')
          renderer.render_names(item, node).should == 'Poe'
        end

        it 'supports nested label node' do
          node << CSL::Style::Label.new(:prefix => ' [', :suffix => ']')
          renderer.render_names(item, node).should == 'Edgar Allen Poe [author]'
        end
      end

      describe 'given multiple names for a single variable' do
        before do
          item.data.editor = philosophers
          node[:variable] = 'editor'
        end

        it 'formats them as a list' do
          renderer.render_names(item, node).should == 'Plato, Socrates, Aristotle'
        end

        it 'supports nested name node options' do
          node << CSL::Style::Name.new(:and => 'symbol')
          renderer.render_names(item, node).should == 'Plato, Socrates, & Aristotle'
        end

        it 'supports nested label node' do
          node << CSL::Style::Label.new(:prefix => ' (', :suffix => ')')
          renderer.render_names(item, node).should == 'Plato, Socrates, Aristotle (editors)'
        end
      end

      describe 'given multiple variables' do
        before do
          node[:variable] = 'author editor'
          node[:delimiter] = '; '
        end

        it 'renders all matching lists combinded using default delimiter' do
          renderer.render_names(item, node).should == ''

          item.data.author = poe
          renderer.render_names(item, node).should == 'Edgar Allen Poe'

          item.data.editor = philosophers
          renderer.render_names(item, node).should == 'Edgar Allen Poe; Plato, Socrates, Aristotle'
        end

        it 'keeps the variable order' do
          item.data.author = poe
          item.data.editor = philosophers

          node[:variable] = 'editor author'
          renderer.render_names(item, node).should == 'Plato, Socrates, Aristotle; Edgar Allen Poe'
        end

        it 'supports labels' do
          item.data.author = poe
          item.data.editor = philosophers

          node << CSL::Style::Label.new(:prefix => ' (', :suffix => ')')

          renderer.render_names(item, node).should == 'Edgar Allen Poe (author); Plato, Socrates, Aristotle (editors)'
        end

        it 'resolves the editor translator special case' do
          renderer.format = :text

          node[:variable] = 'translator author editor'

          item.data.editor = 'Patrick F. Quinn and G. R. Thompson'
          item.data.author = poe

          node.name = { :and => 'symbol', :form => 'short' }
          node.label = { :prefix => ' (', :suffix => ')' }

          renderer.render_names(item, node).should == 'Poe (author); Quinn & Thompson (editors)'

          item.data.translator = poe
          renderer.render_names(item, node).should == 'Poe (translator); Poe (author); Quinn & Thompson (editors)'

          item.data.translator = 'Patrick F. Quinn and G. R. Thompson'

          renderer.render(item, node).should == 'Quinn & Thompson (editors & translators); Poe (author)'
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
          renderer.render_name(CiteProc::Names.new, node).should == ''
        end

        it 'formats the given name in long form' do
          renderer.render_name(poe, node).should == 'Edgar Allen Poe'
        end

        it 'formats multiple names delimitted by commas' do
          renderer.render_name(philosophers, node).should == 'Plato, Socrates, Aristotle'
        end
      end

      describe 'given a node with and "and" attribute' do
        it 'inserts a delimited connector' do
          node[:and] = 'symbol'
          renderer.render_name(philosophers, node).should == 'Plato, Socrates, & Aristotle'

          node[:and] = 'text'
          renderer.render_name(philosophers, node).should == 'Plato, Socrates, and Aristotle'
        end
      end

      describe 'given a node with delimier-precedes-last' do
        it 'inserts final delimiter only for three or more names when set to "contextual"' do
          node.delimiter_contextually_precedes_last!
          renderer.render_name(philosophers, node).should == 'Plato, Socrates, Aristotle'

          node[:and] = 'text'
          renderer.render_name(philosophers, node).should == 'Plato, Socrates, and Aristotle'

          renderer.render_name(philosophers.take(2), node).should == 'Plato and Socrates'

          node[:and] = nil
          renderer.render_name(philosophers.take(2), node).should == 'Plato, Socrates'
        end

        it 'inserts final delimiter when set to "always"' do
          node.delimiter_always_precedes_last!

          renderer.render_name(philosophers, node).should == 'Plato, Socrates, Aristotle'

          node[:and] = 'text'
          renderer.render_name(philosophers, node).should == 'Plato, Socrates, and Aristotle'

          renderer.render_name(philosophers.take(2), node).should == 'Plato, and Socrates'

          node[:and] = nil
          renderer.render_name(philosophers.take(2), node).should == 'Plato, Socrates'
        end

        it 'never inserts final delimiter when set to "never" (unless there is no "and")' do
          node.delimiter_never_precedes_last!

          renderer.render_name(philosophers, node).should == 'Plato, Socrates, Aristotle'
          renderer.render_name(philosophers.take(2), node).should == 'Plato, Socrates'

          node[:and] = 'text'
          renderer.render_name(philosophers, node).should == 'Plato, Socrates and Aristotle'
          renderer.render_name(philosophers.take(2), node).should == 'Plato and Socrates'
        end

        it 'supports only-after-inverted-name rule' do
          names = CiteProc::Names.new('Doe, J. and Smith, S. and Williams, T.')
          node.delimiter_precedes_last_after_inverted_name!

          # always delimit when there is no and!
          renderer.render_name(names, node).should == 'J. Doe, S. Smith, T. Williams'
          renderer.render_name(names.take(2), node).should == 'J. Doe, S. Smith'

          node[:and] = 'text'
          renderer.render_name(names, node).should == 'J. Doe, S. Smith and T. Williams'
          renderer.render_name(names.take(2), node).should == 'J. Doe and S. Smith'

          node[:'name-as-sort-order'] = 'first'
          renderer.render_name(names, node).should == 'Doe, J., S. Smith and T. Williams'
          renderer.render_name(names.take(2), node).should == 'Doe, J., and S. Smith'

          node[:'name-as-sort-order'] = 'all'
          renderer.render_name(names, node).should == 'Doe, J., Smith, S., and Williams, T.'
          renderer.render_name(names.take(2), node).should == 'Doe, J., and Smith, S.'
        end
      end

      describe 'truncation of name lists' do
        let(:names) { CiteProc::Names.new('Doe, J. and Smith, S. and Williams, T.') }

        it 'supports et-al formatting via an et-al node' do
          node[:'et-al-min'] = 3
          node[:'et-al-use-first'] = 2

          others = CSL::Style::EtAl.new(:prefix => '!!')
          node.stub(:et_al).and_return(others)

          renderer.render_name(names, node).should == 'J. Doe, S. Smith, !!et al.'

          others[:term] = 'and others'
          renderer.render_name(names, node).should == 'J. Doe, S. Smith, !!and others'
        end

        it 'supports et-al-use-last' do
          node[:'et-al-min'] = 3
          node[:'et-al-use-first'] = 2
          node[:'et-al-use-last'] = true

          # truncated list must be at least two names short!
          renderer.render_name(names, node).should == 'J. Doe, S. Smith, et al.'

          node[:'et-al-use-first'] = 1
          renderer.render_name(names, node).should == 'J. Doe, … T. Williams'
        end

        describe 'with default delimiter settings' do
          it 'truncates the list if it matches or exceeds et-al-min' do
            node[:'et-al-min'] = 3
            node[:'et-al-use-first'] = 2

            renderer.render_name(names, node).should == 'J. Doe, S. Smith, et al.'

            node[:'et-al-use-first'] = 1
            renderer.render_name(names, node).should == 'J. Doe et al.'
          end

          it 'does not truncate the list if it is less than et-al-min' do
            node[:'et-al-min'] = 4
            node[:'et-al-use-first'] = 2

            renderer.render_name(names, node).should == 'J. Doe, S. Smith, T. Williams'
          end
        end

        describe 'with delimiter-precedes-et-al set' do
          it 'inserts delimiter only for two or more names when set to "contextual" or nil' do
            node.truncate_when! 3
            node.truncate_at! 2

            # default behaviour should match contextual!
            renderer.render_name(philosophers, node).should == 'Plato, Socrates, et al.'

            node.truncate_at! 1
            renderer.render_name(philosophers, node).should == 'Plato et al.'

            # set contextual explicitly
            node.delimiter_contextually_precedes_et_al!
            renderer.render_name(philosophers, node).should == 'Plato et al.'

            node.truncate_at! 2
            renderer.render_name(philosophers, node).should == 'Plato, Socrates, et al.'
          end

          it 'inserts delimiter when set to "always"' do
            node.truncate_when! 3
            node.truncate_at! 2

            node.delimiter_always_precedes_et_al!
            renderer.render_name(philosophers, node).should == 'Plato, Socrates, et al.'

            node.truncate_at! 1
            renderer.render_name(philosophers, node).should == 'Plato, et al.'
          end

          it 'never inserts delimiter when set to "never"' do
            node.truncate_when! 3
            node.truncate_at! 2

            node.delimiter_never_precedes_et_al!
            renderer.render_name(philosophers, node).should == 'Plato, Socrates et al.'

            node.truncate_at! 1
            renderer.render_name(philosophers, node).should == 'Plato et al.'
          end

          it 'supports only-after-inverted-name rule' do
            node.truncate_when! 3
            node.truncate_at! 2

            node.delimiter_precedes_et_al_after_inverted_name!

            renderer.render_name(names, node).should == 'J. Doe, S. Smith et al.'

            node[:'name-as-sort-order'] = 'first'
            renderer.render_name(names, node).should == 'Doe, J., S. Smith et al.'

            node.truncate_at! 1
            renderer.render_name(names, node).should == 'Doe, J., et al.'

            node[:'name-as-sort-order'] = 'all'
            renderer.render_name(names, node).should == 'Doe, J., et al.'

            node.truncate_at! 2
            renderer.render_name(names, node).should == 'Doe, J., Smith, S., et al.'
          end
        end
      end

      describe 'name-part formatting' do
        let(:part) { CSL::Style::NamePart.new(:'text-case' => 'uppercase') }
        before { node.parts << part }

        it 'supports family name formatting' do
          part[:name] = 'family'
          renderer.render_name(poe, node).should == 'Edgar Allen POE'
        end

        it 'family part includes non-demoted particles' do
          part[:name] = 'family'

          renderer.render_name(people(:la_fontaine), node).should == 'Jean de LA FONTAINE'
          renderer.render_name(people(:humboldt), node).should == 'Alexander von HUMBOLDT'
          renderer.render_name(people(:van_gogh), node).should == 'Vincent VAN GOGH'
        end

        it 'family part affixes includes name suffix for non-inverted names' do
          part.merge! :name => 'family', :prefix => '(', :suffix => ')'

          la_fontaine = people(:la_fontaine)
          la_fontaine[0].suffix = 'Jr.'

          renderer.render_name(la_fontaine, node).should == 'Jean de (LA FONTAINE Jr.)'
        end

        it 'supports given name formatting' do
          part[:name] = 'given'
          renderer.render_name(poe, node).should == 'EDGAR ALLEN Poe'
        end

        it 'given part includes particles' do
          part[:name] = 'given'

          renderer.render_name(people(:la_fontaine), node).should == 'JEAN DE La Fontaine'
          renderer.render_name(people(:humboldt), node).should == 'ALEXANDER VON Humboldt'
          renderer.render_name(people(:van_gogh), node).should == 'VINCENT van Gogh'
        end

        it 'given part affixes enclose demoted particles' do
          part.merge! :name => 'given', :prefix => '(', :suffix => ')'

          la_fontaine = people(:la_fontaine)

          renderer.render_name(la_fontaine, node).should == '(JEAN DE) La Fontaine'

          node.all_names_as_sort_order!
          renderer.render_name(la_fontaine, node).should == 'La Fontaine, (JEAN DE)'

          la_fontaine[0].always_demote_particle!
          renderer.render_name(la_fontaine, node).should == 'Fontaine, (JEAN DE La)'
        end

        it 'does not alter the passed-in name object' do
          part[:name] = 'family'
          renderer.render_name(poe, node).should == 'Edgar Allen POE'
          poe.to_s.should == 'Edgar Allen Poe'
        end
      end
    end
  end
end
