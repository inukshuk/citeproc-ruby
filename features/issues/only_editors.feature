Feature: Only Editors
  As a user of CiteProc-Ruby
  I want to process books that have no authors but only editors
  And I do not want the editors to be duplicated

	Scenario: APA Book Editors
	  When I generate an apa-style bibliography for:
	    """
      [{
        "id": "foo",
        "type": "book",
        "editor": [
          {"family": "Berger", "given": "Franz"},
          {"family": "Korunka", "given": "Christian"}
        ],
        "title": "Person",
        "publisher": "Springer",
        "issued": {"date-parts": [[2011]]}
      }]
      """
    Then the result should match:
      """
      Berger, F\., & Korunka, C\. \(Eds\.\)\. \(2011\)\. Person
      """
