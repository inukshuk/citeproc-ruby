# coding: utf-8

module Fixtures

	module_function

	def people(name)
		PEOPLE[name.to_sym]
	end

	def items(name)
		item = CiteProc::CitationItem.new(:id => name)
		item.data = ITEMS[name.to_sym].dup
		item
	end

	PEOPLE = {
		:poe => CiteProc::Names.new(:family => 'Poe', :given => 'Edgar Allen'),

		:plato => CiteProc::Name.new(:given => 'Plato'),

		:japanese => CiteProc::Name.new(:family => '穂積', :given => '陳重'),

		:humboldt => CiteProc::Name.new(:given => 'Alexander',
			:particle => 'von', :family => 'Humboldt'),

		:derrida => CiteProc::Name.new(:given => 'Jacques', :family => 'Derrida')
	}

	ITEMS = {
    :knuth1968 => CiteProc::Item.new(
      :id => 'knuth1968',
      :type => 'book',
      :title => 'The art of computer programming',
      :author => 'Donald Knuth',
      :publisher => 'Addison-Wesley',
      :volume => 1,
      :issued => 1968,
      :'publisher-place' => 'Boston'
    ),

		:grammatology => CiteProc::Item.new(
			:id => 'grammatology',
      :type => 'book',
			:title => 'Of Grammatology',
			:author => people(:derrida),
			#:edition => 'corrected edition',
			:issued => 1976,
			:publisher => 'Johns Hopkins University Press',
			:'publisher-place' => 'Baltimore'
		)
	}

end
