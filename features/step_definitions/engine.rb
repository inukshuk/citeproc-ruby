Given(/^the following style:$/) do |string|
  @style = CSL::Style.parse!(string)
end

When(/^I cite the following items as "(.*?)":$/) do |format, items|
  processor = CiteProc::Processor.new :style => @style, format: format

  processor.import items.hashes.map.with_index { |data, idx|
    data[:id] = "ID-#{idx}"
    data
  }

  @results = processor.items.keys.map { |id| processor.process :id => id }
end
