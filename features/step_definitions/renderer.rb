
Given(/^the "(.*?)" style's (bibliography|citation) node$/) do |style, mode|
  @node = CSL::Style.load(style).send(mode).layout
end

Given(/^the following style node:$/) do |string|
  @node = CSL.parse!(string, CSL::Style)
end

Given(/^the following sort keys:$/) do |string|
  @sort = CSL.parse!(string, CSL::Style)
end

Given(/^the following macro:$/) do |string|
  @macro = CSL.parse!(string, CSL::Style)
end

When(/^I render the following citation items as "(.*?)":$/) do |format, items|
  r = CiteProc::Ruby::Renderer.new(:format => format)

  @results = items.hashes.map.with_index do |data, idx|
    i = CiteProc::CitationItem.new(:id => "ID-#{idx}")

    data[:id] = "ID-#{idx}"
    i.data = CiteProc::Item.new(data)

    r.render i, @node
  end
end

When(/^I render the following citation item as "(.*?)":$/) do |format, item|
  r = CiteProc::Ruby::Renderer.new(:format => format)

  i = CiteProc::CitationItem.new(:id => 'ID-1')
  i.data = CiteProc::Item.new(item.rows_hash.merge(:id => 'ID-1'))

  @result = r.render i, @node
end

When(/^I sort the following items:$/) do |items|
  engine = CiteProc::Ruby::Engine.new

  @order = items.hashes.map.with_index do |data, idx|
    data[:id] = "ID-#{idx}"
    CiteProc::Item.new(data)
  end

  unless @macro.nil?
    @sort.each_child do |key|
      key.stub(:macro).and_return(@macro)
      key.stub(:macro?).and_return(true)
    end
  end

  engine.sort! @order, @sort.children
end

Then(/^the results should be:$/) do |expected|
  expected = expected.raw.map(&:first)

  @results.length.should == expected.length

  @results.zip(expected).each do |result, expectation|
    result.should == expectation
  end
end

Then(/^the result should be: (.*)$/) do |expected|
  @result.should == expected
end

Then(/^the order should be:$/) do |expected|
  expected = expected.raw.map(&:first)

  @order.length.should == expected.length

  @order.zip(expected).each do |order, expectation|
    order['id'].should == expectation
  end
end
