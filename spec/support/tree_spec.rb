require 'spec_helper'

describe Support::Tree do
  
  before(:each) { Object.instance_eval { include Support::Tree } }
  
  let(:node) { Object.new }
  
  describe '#children' do
    context 'when it has no children' do
      it 'returns an empty list' do
        node.children.should be_empty
      end
    end
    
    context 'when it has children' do
      before(:each) { node.add_children([Object.new, Object.new, Object.new]) }
      
      it 'returns a list of all children' do
        node.children.should have(3).items
      end
    end
  end
  
  describe '#name' do
    it 'returns the class name in attribute form by default' do
      node.name.should == 'object'
    end
  end
  
  describe '#add_children' do
    it 'adds a single node to the children array' do
      node.add_children(Object.new).children.should have(1).item
    end
    
    it 'adds a list of nodes to the children array' do
      node.add_children(Object.new, Object.new).children.should have(2).item
    end

    it 'adds an array of nodes to the children array' do
      node.add_children([Object.new, Object.new]).children.should have(2).item
    end
    
    it 'sets self as parent of the added nodes' do
      node.add_children([Object.new, Object.new]).children.map(&:parent).uniq.should == [node]
    end

    it 'does not alter the state if no argument given' do
      node.add_children().children.should be_empty
    end
    
    it 'does not alter the state if nil argument given' do
      node.add_children(nil).children.should be_empty
    end

    it 'does not alter the state if nil arguments given' do
      node.add_children(nil, nil).children.should be_empty
    end

    it 'does not alter the state if empty list argument given' do
      node.add_children([]).children.should be_empty
    end

    it 'does not alter the state if nil list argument given' do
      node.add_children([nil, nil]).children.should be_empty
    end
    
  end
  
  describe '#ancestors' do
    context 'when it has no ancestors' do
      it 'returns and empty list' do
        node.ancestors.should be_empty
      end
    end
    
    context 'when it has ancestors' do
      
      let(:node1) { node.add_children(Object.new).children[0] }
      let(:node2) { node1.add_children(Object.new).children[0] }
      let(:node3) { node2.add_children(Object.new).children[0] }

      it 'returns a list containing the ancestors (depth 0)' do
        node.ancestors.should be_empty
      end
      
      it 'returns a list containing the ancestors (depth 1)' do
        node1.ancestors.should == [node]
      end

      it 'returns a list containing the ancestors (depth 2)' do
        node2.ancestors.should == [node1, node]
      end

      it 'returns a list containing the ancestors (depth 3)' do
        node3.ancestors.should == [node2, node1, node]
      end
      
    end
  end

  describe '#root' do
    context 'when it has no ancestors' do
      it 'returns itself' do
        node.root.should == node
        node.should be_root
      end
    end
    
    context 'when it has ancestors' do
      
      let(:node1) { node.add_children(Object.new).children[0] }
      let(:node2) { node1.add_children(Object.new).children[0] }
      let(:node3) { node2.add_children(Object.new).children[0] }
  
      it 'returns the root node (depth 0)' do
        node.root.should == node
        node.should be_root
        node.depth.should == 0
      end

      it 'returns the root node (depth 1)' do
        node1.root.should == node
        node1.should_not be_root
        node1.depth.should == 1
      end

      it 'returns the root node (depth 2)' do
        node2.root.should == node
        node2.should_not be_root
        node2.depth.should == 2
      end

      it 'returns the root node (depth 3)' do
        node3.root.should == node
        node3.should_not be_root
        node3.depth.should == 3
      end
    end
  end
  
  describe 'named child accessors' do
    
    before(:all) { Object.instance_eval { attr_children :object } }
    
    context 'when it has no children' do
      it 'returns an empty list by default' do
        Object.new.object.should be_empty
      end
    end
    
    context 'when it has children' do
      it 'returns a list of a single child with the matching name' do
        Object.new.add_children(Object.new).object.should have(1).item
      end

      it 'returns a list of all children with the matching name' do
        Object.new.add_children(Object.new, Object.new).object.should have(2).items
      end
    end
  end
  
end