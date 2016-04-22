Feature: Rendering bibliography nodes
  As a hacker of cite processors
  I want to render citation items
  Using bibliography nodes

  Scenario: Rendering APA style bibliographies as text in English
    Given the "apa-with-different-translations" style's bibliography node
    When I render the following citation items as "text":
      | type            | author           | title                 | issued           | translator             | container-title     | page   | issue |
      | paper-conference            | Thomas Pynchon   | The crying of lot 49  | July 7, 2006 | Harald Hard        |                     |        |       |
      | paper-conference | Derrida, Jacques | The purveyor of truth | 1975             | Jina Harder        | Yale French Studies | 31-113 | 52    |
    Then the results should be:
      | Pynchon, T. (2006). The crying of lot 49. In H. Hard (Who translated this piece on her/his own), . |
      | Derrida, J. (1975). The purveyor of truth. In J. Harder (Who translated this piece on her/his own), Yale French Studies (pp. 31–113). |

  Scenario: Rendering APA style bibliographies as text in French
    Given the "apa-with-different-translations" style's bibliography node
    Given the "fr" locale
    When I render the following citation items as "text":
      | type            | author           | title                 | issued           | translator             | container-title     | page   | issue |
      | paper-conference            | Thomas Pynchon   | The crying of lot 49  | July 7, 2006 | Harald Hard        |                     |        |       |
      | paper-conference | Derrida, Jacques | The purveyor of truth | 1975             | Jina Harder        | Yale French Studies | 31-113 | 52    |
    Then the results should be:
      | Pynchon, T. (2006). The crying of lot 49. In H. Hard (Le merveilleux traducteur), . |
      | Derrida, J. (1975). The purveyor of truth. In J. Harder (Le merveilleux traducteur), Yale French Studies (p. 31‑113). |

  Scenario: Rendering APA style bibliographies as text in German (a language where the style has no explicit terms for)
    Given the "apa-with-different-translations" style's bibliography node
    Given the "de" locale
    When I render the following citation items as "text":
      | type            | author           | title                 | issued           | translator             | container-title     | page   | issue |
      | paper-conference            | Thomas Pynchon   | The crying of lot 49  | July 7, 2006 | Harald Hard        |                     |        |       |
      | paper-conference | Derrida, Jacques | The purveyor of truth | 1975             | Jina Harder        | Yale French Studies | 31-113 | 52    |
    Then the results should be:
      | Pynchon, T. (2006). The crying of lot 49. In H. Hard (Übers.), . |
      | Derrida, J. (1975). The purveyor of truth. In J. Harder (Übers.), Yale French Studies (S. 31–113). |
