Feature: Bibsection include

	@citeproc-test @bibliography @v1.0 @bibsection
	Scenario: include
		Given a CSL processor
		And the CSL style
		"""
		<style 
		      xmlns="http://purl.org/net/xbiblio/csl"
		      class="note"
		      version="1.0">
		  <info>
		    <id />
		    <title />
		    <updated>2009-08-10T04:49:00+09:00</updated>
		  </info>
		  <citation>
		    <layout>
		      <text value="Oops"/>
		    </layout>
		  </citation>
		  <bibliography>
		    <sort>
		      <key variable="title" />
		    </sort>
		    <layout>
		      <text variable="title" />
		    </layout>
		  </bibliography>
		</style>
		"""
		And the following items
		"""
		[
		    {
		        "id": "ITEM-1", 
		        "title": "Book C", 
		        "type": "book"
		    }, 
		    {
		        "id": "ITEM-2", 
		        "title": "Article B", 
		        "type": "article-journal"
		    }, 
		    {
		        "id": "ITEM-3", 
		        "title": "Book A", 
		        "type": "book"
		    }
		]
		
		"""
		When I generate a bibliography with the argument
		"""
		{ 
		   "include": [ 
		      {
		         "field": "type",
		         "value": "book"
		      }
		   ]
		}
		"""
		Then the result should be
		"""
		<div class="csl-bib-body">
		  <div class="csl-entry">Book A</div>
		  <div class="csl-entry">Book C</div>
		</div>
		"""