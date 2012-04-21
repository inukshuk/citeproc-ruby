Given /^a CSL processor$/ do
  @processor = CiteProc::Processor.new
end

Given /^the following items$/ do |items|
  @processor.import(JSON.parse(items))
end

Given /^the CSL style:?$/ do |style|
  @style = style
end

When /^I process the citation items$/ do |items|
  @processor.style = @style if @style
  @procesor.format = @format if @format
  @result = JSON.parse(items).map { |d| @processor.cite(d).map { |c| c[1] }.join }.join("\n")
end

When /^I process the following items:$/ do |table|
  @result = CiteProc.process(table.hashes, :mode => :citation,
    :style => @style, :format => @format, :locale => @locale)[0]
end

Then /^the result should be:?$/ do |string|
  @result.should == string
end

Then /^the result should match:?$/ do |pattern|
  @result.should =~ Regexp.compile(pattern)
end

When /^I generate a bibliography with the argument$/ do |argument|
  @processor.style = @style if @style
  @procesor.format = @format if @format
  @result = @processor.bibliography(JSON.parse(argument)).to_s
end

When /^I set the format to "([^"]*)"$/ do |format|
  @format = format.downcase
end

When /^I generate an? (\w+)-style bibliography for:$/ do |style, items|
  @result = CiteProc.process(JSON.parse(items), :style => style)
end

When /^I generate an? (\w+)-style bibliography in the language "([\w-]+)" for:$/ do |style, locale, items|
  @result = CiteProc.process(JSON.parse(items), :style => style, :locale => locale)
end


When /^I process the items using with the style "([^"]+)"$/ do |style|
  @result = CiteProc.process(@items, :style => style)
end

