module CiteProc
  describe Formatter do
    
    it { should_not be_nil }
    
    describe '#format' do
      it 'returns the current format by default' do
        Formatter.new.format.should be_a_kind_of(Format::Default)
      end
      
      it 'applies the current format if arguments are given' do
        Formatter.new.format('foo').should == 'foo'
      end 
    end

    describe '#apply' do
      
      it 'returns an empty string by default' do
        Formatter.new.apply.should == ''
      end
      
      context 'using the default style' do
        
        let(:format) { Formatter.new }
        
        it 'returns the given string if there are no attributes' do
          format.apply('foo') == 'foo'
        end
        
        it 'returns the formatted string (prefix)' do
          format.apply('foo', 'prefix' => '@').should == '@foo'
        end
        
        it 'returns the formatted string (suffix)' do
          format.apply('foo', 'suffix' => '@').should == 'foo@'
        end
        
        it 'returns the formatted string (affixes)' do
          format.apply('foo', 'prefix' => '@', 'suffix' => '@').should == '@foo@'
        end

        it 'returns the formatted string (display)' do
          format.apply('foo', 'display' => 'block').should == 'foo'
          format.apply('foo', 'display' => 'inline').should == 'foo'
          format.apply('foo', 'display' => 'right-inline').should == 'foo'
          format.apply('foo', 'display' => 'left-margin').should == 'foo'
        end
        
        it 'returns the formatted string (strip periods)' do
          format.apply('foo', 'strip-periods' => 'true').should == 'foo'
          format.apply('foo.', 'strip-periods' => 'true').should == 'foo'
          format.apply('f.oo.', 'strip-periods' => 'true').should == 'f oo'
          format.apply('.foo.', 'strip-periods' => 'true').should == 'foo'
          format.apply('foo...', 'strip-periods' => 'true').should == 'foo'
        end
        
        it 'returns the formatted string (font-style)' do
          format.apply('foo', 'font-style' => 'normal').should == 'foo'
          format.apply('foo', 'font-style' => 'italic').should == 'foo'
          format.apply('foo', 'font-style' => 'italics').should == 'foo'
          format.apply('foo', 'font-style' => 'oblique').should == 'foo'
        end

        it 'returns the formatted string (font-variant)' do
          format.apply('foo', 'font-variant' => 'normal').should == 'foo'
          format.apply('foo', 'font-variant' => 'small-caps').should == 'foo'
        end

        it 'returns the formatted string (font-weight)' do
          format.apply('foo', 'font-weight' => 'normal').should == 'foo'
          format.apply('foo', 'font-weight' => 'bold').should == 'foo'
          format.apply('foo', 'font-weight' => 'light').should == 'foo'
        end

        it 'returns the formatted string (text-decoration)' do
          format.apply('foo', 'text-decoration' => 'none').should == 'foo'
          format.apply('foo', 'text-decoration' => 'underline').should == 'foo'
        end

        it 'returns the formatted string (vertical-align)' do
          format.apply('foo', 'vertical-align' => 'baseline').should == 'foo'
          format.apply('foo', 'vertical-align' => 'sub').should == 'foo'
          format.apply('foo', 'vertical-align' => 'sup').should == 'foo'
        end

        it 'returns the formatted string (text-case)' do
          format.apply('foo', 'text-case' => 'none').should == 'foo'
          format.apply('foo Foo FOO', 'text-case' => 'lowercase').should == 'foo foo foo'
          format.apply('foo Foo FoO', 'text-case' => 'uppercase').should == 'FOO FOO FOO'
          format.apply('foo foo foo', 'text-case' => 'capitalize-first').should == 'Foo foo foo'
          format.apply('foo FOO fOo', 'text-case' => 'capitalize-all').should == 'Foo Foo Foo'
          format.apply('the short story of foo and bar', 'text-case' => 'title').should == 'The Short Story of Foo and Bar'
          format.apply('the short story of FOO and BAR', 'text-case' => 'title').should == 'The Short Story of FOO and BAR'
          format.apply('the short story of foo and bar', 'text-case' => 'sentence').should == 'The short story of foo and bar'
        end

      end

    end
  end
end