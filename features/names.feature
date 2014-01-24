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

  Scenario: Initials when given part is uppercased
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


  Scenario: Name as sort order
    Given the following style node:
      """
      <names variable="author">
        <name and="text" delimiter=", " delimiter-precedes-last="always" name-as-sort-order="first" sort-separator=", " />
      </names>
      """
    When I render the following citation items as "html":
      | author                  |
      | John Doe                |
      | John Doe and Jane Doe   |
    Then the results should be:
      | Doe, John               |
      | Doe, John, and Jane Doe |

  Scenario: Substitutions
    Given the following style node:
      """
      <names variable="author">
        <name and="text" delimiter=", " delimiter-precedes-last="always" name-as-sort-order="first" sort-separator=", " />
        <substitute>
          <names variable="editor"/>
          <text value="UNKNOWN"/>
        </substitute>
      </names>
      """
    When I render the following citation items as "html":
      | editor                  |
      | John Doe                |
      |                         |
      | John Doe and Jane Doe   |
    Then the results should be:
      | Doe, John               |
      | UNKNOWN                 |
      | Doe, John, and Jane Doe |

  Scenario: Suppression after substitutions
    Given the following style node:
      """
      <group delimiter=", ">
        <names variable="author">
          <name and="text" delimiter=", " delimiter-precedes-last="always" name-as-sort-order="first" sort-separator=", " />
          <substitute>
            <names variable="editor"/>
            <text variable="title"/>
          </substitute>
        </names>
        <names variable="editor">
          <label prefix=" (" suffix=")"/>
        </names>
        <text variable="title" text-case="uppercase"/>
      </group>
      """
    When I render the following citation items as "html":
      | editor                  | author                  | title     |
      | John Doe                | Jane Doe                | The Title |
      | John Doe                |                         | The Title |
      |                         |                         | The Title |
    Then the results should be:
      | Doe, Jane, John Doe (editor), THE TITLE           |
      | Doe, John, THE TITLE                              |
      | The Title                                         |
