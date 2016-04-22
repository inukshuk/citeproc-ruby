Given(/^the following style:$/) do |string|
  @style = CSL::Style.parse!(string)
end

Given(/^the "(.*?)" style$/) do |style|
  @style = CSL::Style.load(style)
end

When(/^I (cite|reference) the following items as "(.*?)":$/) do |mode, format, items|
  processor = CiteProc::Processor.new :style => @style, format: format, locale: @locale
  mode = if mode == 'cite' then :citation else :bibliography end

  processor.import items.hashes.map.with_index { |data, idx|
    data[:id] = "ID-#{idx}"
    data
  }

  @results = processor.items.keys.map { |id|
    processor.render mode, :id => id
  }.flatten
end
