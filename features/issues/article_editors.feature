Feature: Article Editors
  As a user of CiteProc-Ruby
  I want to process journal articles that include the journal editors

	Scenario: Journal Editors
	  When I generate an apa-style bibliography for:
	    """
      [{
        "id": "katsivelaris2011a",
        "type": "article-journal",
        "author": [{"family": "Katsivelaris", "given": "Margret"}],
        "editor": [
          {"family": "Berger", "given": "Franz"},
          {"family": "Korunka", "given": "Christian"}
        ],
        "container-title": "Person",
        "language": "de",
        "issue": "1",
        "page": "52--61",
        "title": "Personzentrierte Aspekte zur Entwicklung kindlicher Sexualität in der Beziehung zur Mutter",
        "volume": "15",
        "issued": {"date-parts": [[2011]]}
      }]
      """
    Then the result should match:
      """
      \(F\. Berger & C\. Korunka, Eds\.\) Person
      """
