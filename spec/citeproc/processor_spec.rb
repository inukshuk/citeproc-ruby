require 'spec_helper'

module CiteProc
  
  describe Processor do
  
    let(:processor) { Processor.new }
    let(:item) { Hash['author', [{ 'given' => 'Edgar A.', 'family' => 'Poe' }], 'title', 'The Raven', 'type', 'book', 'issued', { 'date-parts' => [[1996]] }, 'publisher', 'Library of America', 'publisher-place', 'New York' ] }

    describe '.process' do
      it 'returns an empty string by default' do
        Processor.process({}).should == ''
      end
      
      it 'returns a formatted citation' do
        Processor.process(item, :mode => :citation, :style => :apa).should == '(Poe, 1996)'
        Processor.process(item, :mode => :citation, :style => :mla).should == '(Poe)'
      end

      it 'returns a formatted bibliographic entry' do
        Processor.process(item, :mode => :bibliography, :style => :apa).should == 'Poe, E. A. (1996). The Raven. New York: Library of America.'
      end
    end
  
    describe '#style' do
      it 'accepts a style name' do
        processor.style = 'apa'
        processor.style.should_not be_nil
      end
    end
    
    describe '#abbreviations' do
      it 'can be set and records new abbreviations' do
        expected = { 'default' => { 'container-title' => { 'long' => 'short' } } }
        processor.abbreviations = expected
        processor.abbreviations.should == expected
      
        alternate = { 'alternate' => { 'container-title' => { 'long' => 'short' } } }
        processor.add_abbreviations(alternate)
        processor.abbreviations.should == expected.merge(alternate)
     
        result = processor.abbreviate('container-title', 'long')
        result.should == 'short'
      
        result = processor.abbreviate('container-title', 'long', 'alternate')
        result.should == 'short'
      
        result = processor.abbreviate('container-title', 'new')
        result.should == 'new'

        result = processor.abbreviate('container-title', 'new', 'alternate')
        result.should == 'new'

        result = processor.abbreviate('hereinafter', 'new')
        result.should == 'new'
      end
    end
    
  end
  
end