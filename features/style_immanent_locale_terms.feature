Feature: Rendering bibliography nodes
  As a hacker of cite processors
  I want to render citation items
  Using bibliography nodes

  Scenario: Rendering APA style bibliographies as text in English
    Given the "apa-with-different-translations" style
    When I reference the following items as "text":
      | type            | author           | title                 | issued       | translator  |
      | book            | Thomas Pynchon   | The crying of lot 49  | July 7, 2006 | Harald Hard |
    Then the results should be:
      | Pynchon, T. (2006). The crying of lot 49. (H. Hard, Who translated this piece on her/his own). |

  Scenario: Rendering APA style bibliographies as text in French
    Given the "apa-with-different-translations" style
    Given the "fr" locale
    When I reference the following items as "text":
      | type            | author           | title                 | issued       | translator  |
      | book            | Thomas Pynchon   | The crying of lot 49  | July 7, 2006 | Harald Hard |
    Then the results should be:
      | Pynchon, T. (2006). The crying of lot 49. (H. Hard, Le merveilleux traducteur). |

  Scenario: Rendering APA style bibliographies as text in German (a language where the style has no explicit terms for)
    Given the "apa-with-different-translations" style
    Given the "de" locale
    When I reference the following items as "text":
      | type            | author           | title                 | issued       | translator  |
      | book            | Thomas Pynchon   | The crying of lot 49  | July 7, 2006 | Harald Hard |
    Then the results should be:
      | Pynchon, T. (2006). The crying of lot 49. (H. Hard, Übers.). |
