# coding: utf-8

module Fixtures

	module_function

	def people(name)
		DB.people[name.to_sym].dup
	end

	def items(name)
		item = CiteProc::CitationItem.new(:id => name)
		item.data = DB.items[name.to_sym].dup
		item
	end

  class DB
    class << self
      attr_reader :people, :items
    end

    @people = {
      :poe => CiteProc::Names.new(:family => 'Poe', :given => 'Edgar Allen'),

      :plato => CiteProc::Names.new(:given => 'Plato'),

      :japanese => CiteProc::Names.new(:family => '穂積', :given => '陳重'),

      :humboldt => CiteProc::Names.new(:given => 'Alexander',
        :dropping_particle => 'von', :family => 'Humboldt'),

      :la_fontaine => CiteProc::Names.new(:family => 'Fontaine', :given => 'Jean',
        :particle => 'La', :dropping_particle => 'de'),

      :van_gogh => CiteProc::Names.new(:family => 'Gogh',
        :given => 'Vincent', :particle => 'van'),

      :derrida => CiteProc::Names.new(:given => 'Jacques', :family => 'Derrida')
    }

    @items = {
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
        :author => @people[:derrida],
        :edition => 'corrected ed',
        :issued => 1976,
        :publisher => 'Johns Hopkins University Press',
        :'publisher-place' => 'Baltimore'
      ),

      :difference => CiteProc::Item.new(
        :id => 'difference',
        :type => 'book',
        :title => 'L’écriture et la différence',
        :author => @people[:derrida],
        :issued => 1967,
        :edition => 1,
        :pages => 446,
        :language => 'fr',
        :publisher => 'Éditions du Seuil',
        :'publisher-place' => 'Paris'
      ),

      :literal_date => CiteProc::Item.new(
        :id => 'literal_date',
        :type => 'book',
        :title => 'L’écriture et la différence',
        :author => @people[:derrida],
        :issued => { 'literal' => 'sometime in 1967' },
        :edition => 1,
        :pages => 446,
        :language => 'fr',
        :publisher => 'Éditions du Seuil',
        :'publisher-place' => 'Paris'
      ),

      :aaron1 => CiteProc::Item.new(
          type: 'website',
          id: 2,
          author: [{given: 'Hank', family: 'Aaron'}],
          title: 'Spitball'
      ),

      :aaron2 => CiteProc::Item.new(
          type: 'website',
          id: 3,
          author: [{given: 'Hank', family: 'Aaron'}],
          title: 'Baseball Fever'
      ),

      :abbott => CiteProc::Item.new(
          type: 'website',
          id: 4,
          title: 'Abbott and Costello',
          :'container-title' => 'McMillan'
      )
    }
  end

end
