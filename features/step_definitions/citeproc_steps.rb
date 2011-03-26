Given /^a CSL processor$/ do
  @processor = CiteProc::Processor.new
end

Given /^the following items$/ do |items|
  @processor.import(JSON.parse(items))
end

Given /^the CSL style$/ do |style|
  @processor.style = style
end


When /^I process the citation items$/ do |items|
  @result = JSON.parse(items).map { |d| @processor.cite(d).map { |c| c[1] }.join }.join("\n")
end

Then /^the result should be$/ do |string|
  @result.should == string
end

When /^I generate a bibliography with the argument$/ do |argument|
  @result = @processor.bibliography(JSON.parse(argument)).to_s
end

When /^I set the format to "([^"]*)"$/ do |format|
  @processor.format = format.downcase
end
