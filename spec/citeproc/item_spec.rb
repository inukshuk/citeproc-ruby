require 'spec_helper'

module CiteProc
  describe Item do
    
    let(:item) { Item.new }
    
    describe '#new' do
      it { should_not be_nil }
    end
    
    describe '.create' do
      it 'accepts parameters and returns a new item containing the parameters' do
        pending #Item.new(:author => 'Poe, Edgar A.').author.family == 'Poe'
      end
    end
        
    describe '#add_observers' do
      it 'adds a new observer to the empty list of observers' do
        expect {
          item.add_observer(stub('observer', :update => nil))
        }.to change { item.count_observers }.from(0).to(1)
      end
      
      it 'adds a new observers to the internal list of observers' do
        expect {
          item.add_observer(stub('observer1', :update => nil))
          item.add_observer(stub('observer2', :update => nil))
          item.add_observer(stub('observer3', :update => nil))
        }.to change { item.count_observers }.from(0).to(3)
      end      
    end
    
    describe '#delete_observers' do
      let(:observer) { stub('observer', :update => nil) }
      
      it 'raises no error if the list of observers is empty' do
        item.delete_observer(observer)
      end

      it 'does not alter the list of observers if the given observer is not currently observing the item' do
        item.add_observer(observer)
        item.count_observers.should == 1
        item.delete_observer(stub('observer2'))
        item.count_observers.should == 1        
      end
      
      it 'removes the given observer from the list of observers' do
        item.add_observer(observer)
        expect {
          item.delete_observer(observer)
        }.to change { item.count_observers }.from(1).to(0)
      end
    end
    
    describe '#[]' do
      it 'returns the value for the given key' do
        item['foo'] = 'foo'
        item['foo'].should == 'foo'
      end
      
      it 'notifies observers on every variable access' do
        observer = stub('observer')
        observer.should_receive(:update).once
        item.add_observer(observer)
        item['foo']
      end
    end
    
  end
end