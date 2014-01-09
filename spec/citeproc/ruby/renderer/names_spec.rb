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
    end
  end
end
