CiteProc-Ruby
=============
CiteProc-Ruby is a [Citation Style Language](http://citationstyles.org/) (CSL)
1.0.1 cite processor written in pure Ruby. This Ruby gem contains the
processor's rendering engine only; for more documentation on the whole
cite processor, please refer to the documentation of the
[citeproc](https://rubygems.org/gems/citeproc) gem instead.

[![Build Status](https://secure.travis-ci.org/inukshuk/citeproc-ruby.png)](http://travis-ci.org/inukshuk/citeproc-ruby)
[![Coverage Status](https://coveralls.io/repos/github/inukshuk/citeproc-ruby/badge.svg?branch=master)](https://coveralls.io/github/inukshuk/citeproc-ruby?branch=master)
[![Code Climate](https://codeclimate.com/github/inukshuk/citeproc-ruby/badges/gpa.svg)](https://codeclimate.com/github/inukshuk/citeproc-ruby)


Install CiteProc-Ruby and all official CSL styles (optional).

    $ [sudo] gem install citeproc-ruby
    $ [sudo] gem install csl-styles

### Using a Processor for full bibliography and citations

A CiteProc::Processor can generate a full bibliography and citations to it. First, you can create one with a certain style, locale, and format.

    require 'citeproc'
    require 'csl/styles'  # optional, for quick access to styles

    # Create a new processor with the desired style,
    # format, and locale.
    cp = CiteProc::Processor.new style: 'apa', format: 'text', locale: "en-US"

    # To see what styles are available in your current
    # environment, run `CSL::Style.ls'; this also works for
    # locales as `CSL::Locale.ls'.

The `format` is generally `html` or `text`.

As an alternative to loading `csl/styles` and passing a string as the `style`, you can also pass a filepath, or a URL. In either case pointing to a CSL style document. See https://github.com/citation-style-language/styles

Next, you need to load your references into the CiteProc::Processor. These need to be in an array of CSL Data Input formatted hashes (See https://github.com/citation-style-language/schema/blob/master/csl-data.json).  The bibtex-ruby gem can convert bibtex to CSL data input:

    cp.import BibTeX.open('./references.bib').to_citeproc

Now, you can render. The processor API provides three main rendering methods: `process`, `append`, or `bibliography`, eg:

    cp.bibligraphy

For simple one-off renditions, you can also call `render` in bibliography or citation mode.

    cp.render :bibliography, id: 'knuth'

This will return a rendered reference, like:

    #-> Knuth, D. (1968). The art of computer programming. Boston: Addison-Wesley.

However, see the Renderer API below for a lighter-weight way to approach this.

### Using a Renderer to render single references or citations

If you don't need to create a full bibliography, but only render citations one at a time, you may find it more convenient, and get better performance, by using a `CiteProc::Ruby::Renderer` directly.

You first have to create a renderer, which has a fixed format (text or html) and locale.

    renderer = CiteProc::Ruby::Renderer.new :format => 'html', :locale => 'en-US'

Now you can pass it individual CSL data input hashes as input, along with a ruby
object representing a style and it's particular rendering mode (citation or bibliography):

    renderer.render csl_data_input_hash, CSL::Style.load("apa").bibliography

### Caching Style, Locale, and other arguments to maximize performance

Loading the Style and Locale from XML files can be a fairly expensive operation. Even more so if you load from a remote URI of course.

While neither the `CiteProc::Processor` nor the `CiteProc::Ruby::Renderer` are thread-safe, Style and Locale objects should be, so long as you aren't mutating them once loaded. To get maximum performance if you are creating multiple Processors or Renderers, you may want to load the Style and Locale objects once, and then pass them in when you create new Processors or Renderers.

Every method shown above that can take a name (or path, or URI) for a locale or style, can also take an already loaded style or locale object.  You can use `CSL::Style#load` and `CSL::Locale.load` to load these.  Both of those methods can take identifiers from the `csl-styles` gem, local filepaths or URIs.

    style = CSL::Style.load("apa")
    locale = CSL::Locale.load("en-US")

    cp = CiteProc::Processor.new style: style, format: 'text', locale: locale

    renderer = CiteProc::Ruby::Renderer.new :format => 'html', :locale => 'en-US'
    renderer.render csl_data_input_hash, style.bibliography

In fact, for the `format` args, instead of passing a string `'html'` or `'text;`, you can pass ruby objects: `CiteProc::Ruby::Formats::Html.new` or `CiteProc::Ruby::Formats::Text.new` as well, although the performance difference is probably minimal.



### Full CSL API

    # CiteProc-Ruby exposes a full CSL API to you; this
    # makes it possible to just alter CSL styles on the
    # fly. For example, what if we want names not to be
    # initialized even though APA style is configured to
    # do so? We could change the CSL style itself, but
    # we can also make a quick adjustment at runtime:
    name = cp.engine.style.macros['author'] > 'names' > 'name'

    # What just happened? We selected the current style's
    # 'author' macro and then descended to the CSL name
    # node via its parent names node. Now we can change
    # this name node and the cite processor output will
    # pick-up the changes right away:
    name[:initialize] = 'false'

    cp.render :bibliography, id: 'knuth'
    #-> Knuth, Donald. (1968). The art of computer programming (Vol. 1). Boston: Addison-Wesley.

    # Note that we have picked 'text' as the output format;
    # if we want to make us of richer output formats we
    # can switch to HTML instead:
    cp.engine.format = 'html'

    cp.render :bibliography, id: 'knuth'
    #-> Knuth, Donald. (1968). <i>The art of computer programming</i> (Vol. 1). Boston: Addison-Wesley.

    # You can also render citations on the fly.
    cp.render :citation, id: 'knuth', locator: '23'
    #-> (Knuth, 1968, p. 23)
    
    # Pass an array if you want to render multiple citations:
    cp.render :citation, [{ id: 'knuth' }, { id: 'perez' }]
    #-> (Knuth, 1968; Perez, 1989)

Documentation
-------------
* [CiteProc Documentation](http://rubydoc.info/gems/citeproc/)
* [CiteProc-Ruby API Documentation](http://rubydoc.info/gems/citeproc-ruby/)
* [CSL-Ruby API Documentation](http://rubydoc.info/gems/csl/)

Optional Dependencies
---------------------
CiteProc-Ruby tries to minimize hard dependencies for increased compatibility.
You can speed up the XML parsing by installing
[Nokogiri](https://rubygems.org/gems/nokogiri); otherwise the REXML from the
Ruby standard library will be used.

Similarly, you can install either of the gems
[EDTF](https://rubygems.org/gems/edtf) or
[Chronic](https://rubygems.org/gems/chronic) to support a wide range of
additional inputs for date variables.

CSL Styles and Locales
----------------------
You can load CSL styles and locales by passing a respective XML string, file
name, or URL. You can also load styles and locales by name if the
corresponding files are installed in your local styles and locale directories.
By default, CSL-Ruby looks for CSL styles and locale files in

    /usr/local/share/csl/styles
    /usr/local/share/csl/locales

You can change these locations by changing the value of `CSL::Style.root` and
`CSL::Locale.root` respectively.

Alternatively, you can `gem install csl-styles` to install all official CSL
styles and locales. To make the styles and locales available, simply
`require 'csl/styles`.

Compatibility
-------------
The cite processor and the CSL API libraries have been developed for MRI,
Rubinius, and JRuby. Please note that we try to support only Ruby versions
1.9.3 and upwards.

Development
-----------
The CiteProc-Ruby source code is
[hosted on GitHub](https://github.com/inukshuk/citeproc-ruby).
You can check out a copy of the latest code using Git:

    $ git clone https://github.com/inukshuk/citeproc-ruby.git

To get started, install the development dependencies and run all tests:

    $ cd citeproc-ruby
    $ bundle install
    $ rake

If you've found a bug or have a question, please open an issue on the
[issue tracker](https://github.com/inukshuk/citeproc-ruby/issues).
Or, for extra credit, clone the CiteProc-Ruby repository, write a failing
example, fix the bug and submit a pull request.

Credits
-------
Thanks to Rintze M. Zelle, Sebastian Karcher, Frank G. Bennett, Jr.,
and Bruce D'Arcus of CSL and citeproc-js fame for their support!

Thanks to Google and the Berkman Center at Harvard University for supporting
this project as part of [Google Summer of Code](https://developers.google.com/open-source/soc/).

Copyright
---------
Copyright 2009-2020 Sylvester Keil. All rights reserved.

Copyright 2012 President and Fellows of Harvard College.

License
-------
CiteProc-Ruby is dual licensed under the AGPL and the FreeBSD license.
