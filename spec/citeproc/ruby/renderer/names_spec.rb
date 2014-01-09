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

      describe 'given an empty node' do
        it 'returns an empty string for an empty item' do
          renderer.render_names(item, node).should == ''
        end

        it 'returns an empty string for an item with variables' do
          item.data.edition = 'foo'
          renderer.render_names(item, node).should == ''
        end
      end

    end

    describe "Renderer#render_name" do
      let(:renderer) { Renderer.new }

      let(:node) { CSL::Style::Name.new }

      let(:poe) { CiteProc::Names.new('Poe, Edgar Allen') }
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
    end
  end
end
