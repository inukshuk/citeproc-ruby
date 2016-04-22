
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

Given(/^the "(.*?)" locale$/) do |locale|
  @locale = locale
end

When(/^I render the following citation items as "(.*?)":$/) do |format, items|
  @locale ||= 'en'
  r = CiteProc::Ruby::Renderer.new(:format => format, :locale => @locale)

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
      allow(key).to receive(:macro).and_return(@macro)
      allow(key).to receive(:macro?).and_return(true)
    end
  end

  engine.sort! @order, @sort.children
end

Then(/^the results should be:$/) do |expected|
  expected = expected.raw.map(&:first)

  expect(@results.length).to eq(expected.length)

  @results.zip(expected).each do |result, expectation|
    expect(result).to eq(expectation)
  end
end

Then(/^the result should be: (.*)$/) do |expected|
  expect(@result).to eq(expected)
end

Then(/^the order should be:$/) do |expected|
  expected = expected.raw.map(&:first)

  expect(@order.length).to eq(expected.length)

  @order.zip(expected).each do |order, expectation|
    expect(order['id']).to eq(expectation)
  end
end
