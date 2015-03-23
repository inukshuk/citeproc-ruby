Feature: Rendering CSL nodes
  As a hacker of cite processors
  I want to render citation items
  With selected CSL nodes

  Scenario: Simple Date Rendering
    Given the following style node:
      """
      <date variable="issued">
        <date-part name="year"/>
      </date>
      """
    When I render the following citation items as "text":
      | issued           |
      | November 7, 2006 |
      | 2014-01-01       |
      | 1999             |
    Then the results should be:
      | 2006             |
      | 2014             |
      | 1999             |

  Scenario: Date Group Rendering
    Given the following style node:
      """
      <group prefix="(" suffix=").">
        <date variable="issued">
          <date-part name="year"/>
        </date>
        <text variable="year-suffix"/>
      </group>
      """
    When I render the following citation items as "text":
      | issued           | year-suffix |
      | November 7, 2006 |             |
      | 2014-01-01       |             |
      | 1999             | a           |
    Then the results should be:
      | (2006).          |
      | (2014).          |
      | (1999a).         |

  @html @formatting
  Scenario: Formatted Groups
    Given the following style node:
      """
      <group>
        <group suffix=" " font-weight="bold">
          <!--group formatting is not pushed down-->
          <text variable="volume" suffix=","/>
        </group>
        <text variable="page" suffix="," font-weight="bold"/>
      </group>
      """
    When I render the following citation item as "html":
      | volume |   5 |
      | page   |  23 |
    Then the result should be: <b>5,</b> <b>23</b>,

  Scenario: Page labels
    Given the following style node:
      """
      <label variable="page"/>
      """
    When I render the following citation items as "text":
      | page   |
      | 23     |
      |        |
      | 23, 34 |
    Then the results should be:
      | page   |
      |        |
      | pages  |

  @group @substitute
  Scenario: Substitute in Groups
    Given the following style node:
      """
      <group>
        <text value="by: "/>
        <names variable="author">
          <substitute>
            <text value="Anonymous"/>
          </substitute>
        </names>
      </group>
      """
    When I render the following citation items as "text":
      | author   |
      | Jane Doe |
      |          |
    Then the results should be:
      | by: Jane Doe  |
      | by: Anonymous |
