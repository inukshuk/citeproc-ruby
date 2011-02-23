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
  # ['affix_InterveningEmpty.json'].include?(File.basename(file))
  # File.basename(file) =~ /parallel_suppressyear/i
  # File.basename(file) =~ /page_/i
  File.basename(file) =~ /name_/i
  # fixture['mode'] == 'citation' && !fixture['citations']
end

describe 'citeproc-test' do

  before(:each) do
    @proc = CiteProc::Processor.new
  end

  CiteProc::Test::Fixtures::Processor.each_pair do |file, fixture|

    tokens = File.basename(file).split(/_|\.json/)
    
    describe tokens[0].downcase do
      
      name = tokens[1].gsub(/([[:lower:]])([[:upper:]])/, '\1 \2').downcase
      
      it name do
        @proc.style = fixture['csl']
        @proc.import(fixture['input'])
        @proc.format = :html
      
        @proc.add_abbreviations(fixture['abbreviations']) if fixture['abbreviations']
      
        case fixture['mode']
        
        when 'citation'
          # citations => process_citation_cluster
          # citation_items || :all => make_citation_cluster
          data = CiteProc::CitationData.parse(fixture['citation_items'] || nil)
        
          if data.empty?
            result = @proc.cite(:all).map { |d| d[1] }.join(', ')
          else
            result = data.map { |d| @proc.cite(d).map { |c| c[1] }.join(', ') }.join("\n")
          end
        
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
      
      end
    end if filter(file, fixture)
  
  end
end