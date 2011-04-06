CiteProc-Ruby
=============

CiteProc-Ruby is a CSL 1.0 ([Citation Style Language](http://citationstyles.org/))
Processor written in Ruby.

A word of caution: this release of CiteProc-Ruby is purely experimental; the API
is not complete and liable to change frequently. This release is expected to
work in Ruby version 1.9.2. only. CiteProc-Ruby currently passes approximately
350 of the 550 tests in the citeproc-test suite.


Quickstart
----------

		$ [sudo] gem install citeproc-ruby
		$ irb
		>> require 'citeproc'
		>> book = {
			'author' => [{ 'given' => 'Edgar Allen', 'family' => 'Poe' }],
			'title' => 'Poetry, Tales, and Selected Essays',
			'type' => 'book',
			'issued' => { 'date-parts' => [[1996]] },
			'editor' => [{ 'family' => 'Quinn', 'given' => 'Patrick F.'}, { 'family' => 'Thompson', 'given' => 'G.R.' }],
			'publisher' => 'Library of America',
			'publisher-place' => 'New York'
		}
		>> CiteProc.process(book)
		=> "Poe, E. A. (1996). Poetry, Tales, and Selected Essays.  (P. F. Quinn & G. R. Thompson, Eds.). New York: Library of America."
		>> CiteProc.process(book, :format => :html)
		=> "Poe, E. A. (1996). <i>Poetry, Tales, and Selected Essays</i>.  (P. F. Quinn &#38; G. R. Thompson, Eds.). New York: Library of America."
		>> CiteProc.process(book, :mode => :citation)
		=> ["(Poe, 1996)"]
		>> CiteProc.process(book, :style => "https://github.com/citation-style-language/styles/raw/master/chicago-author-date.csl")
		=> "Poe, Edgar Allen. 1996. Poetry, Tales, and Selected Essays. Ed. Patrick F. Quinn and G.R. Thompson. New York: Library of America."


The RSpec examples are a valuable resource of usage examples.


Credits
-------

CiteProc-Ruby was written by [Sylvester Keil](http://sylvester.keil.or.at);
thanks to the excellent documentation and specifications of the
[CSL](http://citationstyles.org), [citeproc-js](http://bitbucket.org/fbennett/citeproc-js/wiki/Home),
the [citeproc-test suite](https://bitbucket.org/bdarcus/citeproc-test), and the
kind feedback and support at the [xbiblio mailing list](http://sourceforge.net/mail/?group_id=117435).


License
-------

Copyright 2009-2011 Sylvester Keil. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are
those of the authors and should not be interpreted as representing official
policies, either expressed or implied, of the copyright holder.