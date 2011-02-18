#
# This generates RSpec tests from the JSON test cases of the citeproc-tests
# suite.
#

def not_implemented
  # 'Not implemented'.should == 'Implemented'
end

#
# Filter applied to each test to decide whether we should run it. Use this
# to stay sane while the Processor is not feature complete!
#
def filter(file, fixture)
  ['affix_InterveningEmpty.json'].include?(File.basename(file))
  # fixture['mode'] == 'citation' && !fixture['citations'] && !fixture['citation-items']
end

describe 'citeproc-test' do

  before(:each) do
    @proc = CiteProc::Processor.new
  end

  CiteProc::Test::Fixtures::Processor.each_pair do |file, fixture|

    it File.basename(file) do
      @proc.style = fixture['csl']
      @proc.import(fixture['input'])
      
      case fixture['mode']
        
      when 'citation'
        result = @proc.cite(:all)
        result = result[0][1]
        
      when 'bibliography'
        not_implemented
        
      when 'bibliography-header'
        not_implemented
        
      when 'bibliography-nosort'
        not_implemented
        
      else
        CiteProc.log.warn "unkown processor mode: #{fixture['mode']}"
        not_implemented
      end
      
      result.should == fixture['result']
      
    end if filter(file, fixture)
  
  end
end