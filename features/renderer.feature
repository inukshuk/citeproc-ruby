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

