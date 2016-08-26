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
          <substitute>
            <text variable="title"/>
          </substitute>
        </names>
        <text variable="title" text-case="uppercase"/>
      </group>
      """
    When I render the following citation items as "html":
      | editor                  | author                  | title     |
      | John Doe                | Jane Doe                | The Title |
      |                         | Jane Doe                | The Title |
      | John Doe                |                         | The Title |
      |                         |                         | The Title |
    Then the results should be:
      | Doe, Jane, John Doe (editor), THE TITLE           |
      | Doe, Jane, The Title                              |
      | Doe, John, THE TITLE                              |
      | The Title                                         |

  Scenario: Subsequent author substitutes complete-all with different roles
    Given the following style node:
      """
      <bibliography subsequent-author-substitute="---">
        <layout>
          <group delimiter=" ">
          <names variable="author" delimiter=", " suffix=".">
              <name name-as-sort-order="first"/>
              <substitute>
                <names variable="editor">
                  <name name-as-sort-order="first"/>
                  <label form="short" prefix=" " suffix="."/>
                </names>
              </substitute>
            </names>
            <text variable="title" suffix="."/>
          </group>
        </layout>
      </bibliography>
      """
    When I render the following citation items as "text":
      | editor                  | author                  | title   |
      |                         | Jane Doe                | Title A |
      |                         | Jane Doe                | Title B |
      |                         | John Doe                | Title C |
      | John Doe                |                         | Title D |
      |                         | Jane Doe and John Doe   | Title E |
      |                         | Jane Doe and John Doe   | Title F |
    Then the results should be:
      | Doe, Jane. Title A.           |
      | ---. Title B.                 |
      | Doe, John. Title C.           |
      | --- ed. Title D.              |
      | Doe, Jane, John Doe. Title E. |
      | ---. Title F.                 |

  Scenario: Name / Label Order
    Given the following style node:
      """
      <group delimiter=". ">
        <names variable="author" delimiter=". ">
          <name and="symbol" delimiter=", "/>
          <label prefix=" (" suffix=")"/>
        </names>
        <names variable="translator" delimiter=". ">
          <label form="verb-short" text-case="capitalize-first" suffix=" "/>
          <name and="symbol" delimiter=", "/>
        </names>
      </group>
      """
    When I render the following citation items as "text":
      | translator              | author                  |
      | John Doe                | Jane Doe                |
      | John Doe and Jack Doe   | Jane Doe and Jill Doe   |
    Then the results should be:
      | Jane Doe (author). Trans. John Doe                        |
      | Jane Doe & Jill Doe (authors). Trans. John Doe & Jack Doe |

  Scenario: EtAlUseFirst options
    Given the following style node:
      """
      <group delimiter=" // ">
        <names variable="author">
          <name et-al-min="2" et-al-use-first="0"/>
        </names>
        <names variable="author">
          <name et-al-min="2" et-al-use-first="1"/>
        </names>
      </group>
      """
    When I render the following citation item as "text":
      | author | John Doe and Jane Roe |
    Then the result should be: John Doe et al.


