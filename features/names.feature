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


  @wip
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


