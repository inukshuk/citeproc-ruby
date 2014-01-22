Feature: CSL Name Rendering
  As a CSL hacker
  I want to render names
  Using names nodes

  Scenario: Names Rendering
    Given the following style node:
      """
      <names variable="translator" delimiter=", " prefix="(" suffix=")">
        <name and="symbol" delimiter=", "/>
        <label form="short" prefix=", " text-case="capitalize-first" suffix=""/>
      </names>
      """
    When I render the following citation items as "text":
      | translator                       |
      | Romy Schneider and Peter Sellers |
    Then the results should be:
      | (Romy Schneider & Peter Sellers, Trans.) |


  Scenario: Initials
    Given the following style node:
      """
      <names variable="translator author" delimiter=", " prefix="(" suffix=")">
        <name and="symbol" delimiter=", " initialize-with=". "/>
        <label form="short" prefix=", " text-case="capitalize-first" suffix=""/>
      </names>
      """
    When I render the following citation items as "text":
      | translator                       | author  |
      | Romy Schneider and Peter Sellers |         |
    Then the results should be:
      | (R. Schneider & P. Sellers, Trans.) |

  @wip
  Scenario: ABdNT
    Given the following style node:
      """
      <names variable="author" suffix=".">
        <name name-as-sort-order="all" sort-separator=", " initialize-with=". " delimiter="; " delimiter-precedes-last="always">
          <name-part name="family" text-case="uppercase"/>
          <name-part name="given" text-case="uppercase"/>
        </name>
        <et-al prefix=" " font-style="italic"/>
        <label form="short" prefix=" (" suffix=".)" text-case="uppercase"/>
      </names>
      """
    When I render the following citation items as "html":
      | author                            |
      | Cole, Steven J. and Moore, Robert |
    Then the results should be:
      | COLE, S. J.; MOORE, R.            |

