Feature: Rendering bibliography nodes
  As a hacker of cite processors
  I want to render citation items
  Using bibliography nodes

  Scenario: Rendering APA style bibliographies
    Given the "apa" style's bibliography node
    When I render the following citation items as "text":
      | type    | author           | title                 | issued           | publisher             | container-title     | page   | issue |
      | book    | Thomas Pynchon   | The crying of lot 49  | November 7, 2006 | Harper Perennial      |                     |        |       |
      | article | Derrida, Jacques | The purveyor of truth | 1975             | Yale University Press | Yale French Studies | 31-113 | 52    |
    Then the results should be:
      | Pynchon, Thomas. (2006). The crying of lot 49. Harper Perennial. |
      | Derrida, Jacques. (1975). The purveyor of truth. |

    When I render the following citation item as "text":
      | type            | book             |
      | author          | Vladimir Nabokov |
      | title           | Pale fire        |
      | issued          | April 23, 1989   |
      | publisher       | Vintage          |
      | publisher-place | London           |
    Then the result should be: Nabokov, Vladimir. (1989). Pale fire. London: Vintage.
