Feature: Rendering bibliography nodes
  As a hacker of cite processors
  I want to render citation items
  Using bibliography nodes

  Scenario: Rendering APA style bibliographies as text
    Given the "apa" style's bibliography node
    When I render the following citation items as "text":
      | type            | author           | title                 | issued           | publisher             | container-title     | page   | issue |
      | book            | Thomas Pynchon   | The crying of lot 49  | November 7, 2006 | Harper Perennial      |                     |        |       |
      | article-journal | Derrida, Jacques | The purveyor of truth | 1975             | Yale University Press | Yale French Studies | 31-113 | 52    |
    Then the results should be:
      | Pynchon, T. (2006). The crying of lot 49. Harper Perennial. |
      | Derrida, J. (1975). The purveyor of truth. Yale French Studies, (52), 31–113. |

  Scenario: Rendering APA style bibliographies as HTML
    Given the "apa" style's bibliography node
    When I render the following citation item as "html":
      | type            | book             |
      | author          | Vladimir Nabokov |
      | title           | Pale fire        |
      | issued          | April 23, 1989   |
      | publisher       | Vintage          |
      | publisher-place | London           |
    Then the result should be: Nabokov, V. (1989). <i>Pale fire</i>. London: Vintage.
