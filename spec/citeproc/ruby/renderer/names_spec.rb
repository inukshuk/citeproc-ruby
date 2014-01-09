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
    end
  end
end
