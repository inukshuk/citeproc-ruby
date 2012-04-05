Feature: Invalid Date Error
  As a user of CiteProc-Ruby
  I want given inputs to be processed correctly

	@issue-9
	Scenario: include
	  When I generate an apa-style bibliography for:
	    """
      [{
        "id": "hrimech1998spontaneous",
        "type": "chapter",
        "author": [
          { "family": "Hrimech", "given": "M." },
          { "family": "Bouchard", "given": "Paul" }
        ],
        "collection-title": "Developing paradigms in self-directed learning",
        "editor": [
          { "family": "Long", "given":"H."}
        ],
        "location": "Oklahoma, OK : Oklahoma",
        "page": "27–44",
        "publisher": "University Press",
        "title": "Spontaneous learning strategies in the natural setting",
        "issued": { "date-parts": [[1998]] }
      }]
      """
    Then the result should match:
      """
      ^Hrimech, M\., & Bouchard, P\. \(1998\)\. Spontaneous learning strategies in the natural setting
      """
