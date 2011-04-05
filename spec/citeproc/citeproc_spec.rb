#
# This generates RSpec tests from the JSON test cases of the citeproc-tests
# suite.
#


#
# Filter applied to each test to decide whether we should run it. Use this
# to stay sane while the Processor is not feature-complete!
#
def filter(file, fixture)
  # return ['affix_InterveningEmpty.json'].include?(File.basename(file))
  # File.basename(file) =~ /bugreports_greek/i
  # File.basename(file) =~ /sort_stripmark/i
  # return File.basename(file) =~ /^date_rawparsesimpledate/i
  true
end

module CiteProc
  
  describe 'citeproc' do

    let(:proc) { Processor.new }

    Test::Fixtures::Processor.each_pair do |file, fixture|

      tokens = File.basename(file).split(/_|\.json/)
    
      describe tokens[0].downcase do
      
        name = tokens[1].gsub(/([[:lower:]])([[:upper:]])/, '\1 \2').downcase
      
        it name do
          pending if tokens[0] =~ /^(position|disambiguate|integration|flipflop|collapse|parallel)/
          
          proc.style = fixture['csl']
          proc.import(fixture['input'])
          proc.format = :html

          proc.add_abbreviations(fixture['abbreviations']) if fixture['abbreviations']
      
          case fixture['mode']
        
          when 'citation'
            # citations => process_citation_cluster
            # citation_items || :all => make_citation_cluster
            data = fixture['citation_items']
        
            unless data
              result = proc.cite((fixture['bibentries'] && fixture['bibentries'].last) || :all).map { |d| d[1] }.join
            else
              result = data.map { |d| proc.cite(d).map { |c| c[1] }.join }.join("\n")
            end
        
          when 'bibliography'
            result = proc.bibliography(fixture['bibsection'] || :all).to_s
            
          when 'bibliography-header'
            pending('not yet implemented')
        
          when 'bibliography-nosort'
            pending('not yet implemented')
        
          else
            CiteProc.log.warn "unkown processor mode: #{fixture['mode']}"
            pending('not yet implemented')
          end
      
          result.should == fixture['result']
      
        end
      end if filter(file, fixture)
  
    end
  end
end